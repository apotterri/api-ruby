#!/usr/bin/env rake
require "bundler/gem_tasks"
require "yard"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--order rand'
  end
rescue LoadError
  $stderr.puts "RSpec Rake tasks not available in environment #{ENV['RACK_ENV']}"
end

YARD::Rake::YardocTask.new(:yard)

task :jenkins do
  if ENV['BUILD_NUMBER']
    File.write('build_number', ENV['BUILD_NUMBER'])
  end
  require 'ci/reporter/rake/rspec'
  Rake::Task["ci:setup:rspec"].invoke
  Rake::Task["spec"].invoke
  Rake::Task["yard"].invoke
end

task default: :spec
