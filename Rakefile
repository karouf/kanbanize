require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |test|
  test.libs << 'lib/kanbanize'
  test.test_files = FileList['spec/lib/kanbanize/*_spec.rb', 'spec/lib/kanbanize/*/*_spec.rb']
  test.verbose = true
end

task :default => :test
