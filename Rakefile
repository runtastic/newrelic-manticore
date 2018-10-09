# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

task :init do
  Rake::Task["rubocop:install"].execute
end

require "rubocop/rake_task"
RuboCop::RakeTask.new
namespace :rubocop do
  desc "Install Rubocop as pre-commit hook"
  task :install do
    require "rubocop_runner"
    RubocopRunner.install
  end
end

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test
