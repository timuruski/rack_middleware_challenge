require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << ['lib', 'test']
  t.test_files = FileList['test/*_test.rb']
end

desc "Run all the tests"
task :default => [:test]
