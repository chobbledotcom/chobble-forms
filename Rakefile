require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Generate Sorbet RBI files"
task :sorbet_rbi do
  puts "Generating Sorbet RBI files..."
  system("bundle exec tapioca init") || puts("Tapioca init failed (might already be initialized)")
  system("bundle exec tapioca gem") || puts("Tapioca gem generation failed")
  system("bundle exec tapioca dsl") || puts("Tapioca DSL generation failed")
  puts "Sorbet RBI generation complete."
end

desc "Run Sorbet type checking"
task :typecheck do
  puts "Running Sorbet type checking..."
  system("bundle exec srb tc") || exit(1)
  puts "Type checking passed!"
end
