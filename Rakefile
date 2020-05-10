# frozen_string_literal: true

def build(rake:, gradle:)
  Dir["*/*/{Rakefile,build.gradle}"].each do |file|
    puts "Project '#{File.dirname(file)}'"

    Dir.chdir(File.dirname(file)) do
      if File.basename(file) == "Rakefile"
        sh "rake #{rake}"
      else
        sh "gradle #{gradle}"
      end
    end
  end
end

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
