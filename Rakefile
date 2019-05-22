require 'bundler/gem_tasks'
require 'rake/testtask'
require 'semantic_logger'

desc 'Run core tests'
Rake::TestTask.new do |t|
  t.name = "test:core"
  t.test_files = FileList['test/core/**/*_test.rb']
end

desc 'Run provider integration tests'
Rake::TestTask.new do |t|
  t.name = "test:providers"
  t.test_files = FileList['test/providers/**/*_test.rb']
end

desc 'Run docker integration tests'
Rake::TestTask.new do |t|
  t.name = "test:providers:docker"
  t.test_files = FileList['test/providers/docker/**/*_test.rb']
end

desc 'Run aws integration tests'
Rake::TestTask.new do |t|
  t.name = "test:providers:aws"
  t.test_files = FileList['test/providers/aws/**/*_test.rb']
end

