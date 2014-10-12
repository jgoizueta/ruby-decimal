require "bundler/gem_tasks"

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = Decimal::DECIMAL_VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Decimal #{version}"
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task default: :test
