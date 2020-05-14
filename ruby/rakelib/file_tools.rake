# frozen_string_literal: true

require "uri"

# File tools for Rakefile
module FileTools
  def self.download_zip_archive(source:)
    source = URI(source)
    archive_file = "build/download/#{File.basename(source.path)}"

    download(source: source, target: archive_file)

    if block_given?
      Archive::Zip.open(archive_file) do |archive|
        archive.each do |entry|
          target = yield(entry)

          if target
            puts "Extracting '#{entry.zip_path}' into '#{target}'"
            entry.extract(file_path: target, permissions: true, times: true)
          end
        end
      end
    end

    archive_file
  end

  def self.download_tar_archive(source:)
    source = URI(source)
    archive_file = "build/download/#{File.basename(source.path)}"

    download(source: source, target: archive_file)

    if block_given?
      Minitar::Reader.each_entry(Zlib::GzipReader.new(File.open(archive_file, "rb"))) do |entry|
        target = yield(entry)

        if target
          puts "Extracting '#{entry.full_name}' into '#{target}'"
          save_stream(source: entry, target: target)
        end
      end
    end

    archive_file
  end

  def self.download(source:, target:, mode: nil)
    source = URI(source)

    unless File.exist?(target)
      puts "Downloading '#{source}' into '#{target}'"

      Tempfile.open("download", binmode: true) do |temp_file|
        source.open("rb") do |input|
          IO.copy_stream(input, temp_file)
        end

        temp_file.close

        copy(source: temp_file.path, target: target, mode: mode, info: false)
      end
    end
  end

  def self.file_changed(source:, target:)
    !File.exist?(target) ||
      File.size(source) != File.size(target) ||
      Digest::SHA256.file(source) != Digest::SHA256.file(target)
  end

  def self.copy(source:, target:, mode: nil, info: true)
    if file_changed(source: source, target: target)
      puts "Copying '#{source}' into '#{target}'" if info
      FileUtils.mkpath(File.dirname(target))
      FileUtils.cp(source, target)
    end

    File.chmod(0o755, target) if mode && File.stat(target).mode != mode
  end

  def self.save_stream(source:, target:)
    FileUtils.mkpath(File.dirname(target))

    File.open(target, "wb") do |file|
      file.write(source.read)
    end
  end
end
