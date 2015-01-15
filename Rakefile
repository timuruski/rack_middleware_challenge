require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << ['lib', 'test']
  t.test_files = FileList['test/test_*.rb']
end

desc "Run all the tests"
task :default => [:test]
