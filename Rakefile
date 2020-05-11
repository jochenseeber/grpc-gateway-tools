# frozen_string_literal: true

require "json"
require "open-uri"

PROJECTS = [
  "java/protoc-grpc-gateway-options/build.gradle",
  "ruby/protoc-tools/Rakefile",
  "ruby/protoc-grpc-gateway-options/Rakefile",
  "ruby/protoc-grpc-gateway-plugins/Rakefile"
] + Dir["ruby/examples/**/Rakefile"]

desc "Build all projects"
task "build" do
  build(rake: "build", gradle: "build")
end

desc "Install all projects"
task "install" => "build" do
  build(rake: "install:local", gradle: "publishToMavenLocal")
end

desc "Clean all projects"
task "clean" do
  build(rake: "clobber", gradle: "clean")
end

desc "Update versions, optionally adding a suffix to the version"
task "update_versions", [:suffix] do |_task, params|
  config = {}

  puts "Please enter your Github personal access token:"
  config[:access_token] = STDIN.gets.chomp

  config[:config] = JSON.parse(File.read("project.json"))
  config[:suffix] = params["suffix"]

  update_version(project: "protocolbuffers/protobuf", **config) && changed = true
  update_version(project: "grpc/grpc", **config, suffix: nil) && changed = true
  update_version(project: "grpc-ecosystem/grpc-gateway", **config) && changed = true

  if changed
    File.write("project.json", JSON.pretty_generate(config[:config], indent: " " * 4))

    PROJECTS.select { |f| File.basename(f) == "Rakefile" }.each do |file|
      Dir.chdir(File.dirname(file)) do
        sh "bundle update"
        sh "rake install:local"
      end
    end
  end
end

def build(rake:, gradle:)
  PROJECTS.each do |file|
    puts "Project '#{File.dirname(file)}'"

    Dir.chdir(File.dirname(file)) do
      if rake && File.basename(file) == "Rakefile"
        sh "rake #{rake}"
      elsif gradle && File.basename(file) == "build.gradle"
        sh "gradle #{gradle}"
      end
    end
  end
end

def get_latest_version(project:, access_token:)
  url = URI("https://api.github.com/repos/#{project}/releases")
  result = JSON.parse(url.read("Authorization" => "Bearer #{access_token}"))

  result.map do |r|
    v = r.fetch("tag_name").gsub(%r{^[a-z]+}, "").gsub("-", ".")
    Gem::Version.new(v)
  end.reject(&:prerelease?).max
end

def update_version(config:, project:, access_token:, suffix:)
  project_name = project.split("/").last
  latest_version = get_latest_version(project: project, access_token: access_token)

  current_version = config[project_name]&.[]("version")&.[](%r{^\d+(?:\.\d+)+})&.then { |v| Gem::Version.new(v) }

  if current_version.nil?
    puts "Could not get latest version for #{project}"
    false
  elsif current_version < latest_version
    puts "Updating #{project} to version #{latest_version}"
    (config[project_name] ||= {})["version"] = "#{latest_version}#{suffix}"
    true
  else
    puts "Keeping #{project} at current version #{latest_version}"
    false
  end
end
