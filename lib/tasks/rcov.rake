require 'cucumber/rake/task'
require 'rcov/rcovtask'

namespace :rcov do

  rcov_options = %w{
    --rails
    --exclude osx/objc,gems/*,spec/*,test/*,features/*,seeds/*,bundler/*,features/step_definitions/webrat_steps.rb
    --aggregate "tmp/coverage.data"
  }

  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = "--format pretty"

    t.rcov = true
    t.rcov_opts = rcov_options
  end

  Rcov::RcovTask.new(:tests) do |t|
    t.test_files    =  FileList['test/unit/*_test.rb','test/functional/*_test.rb','test/unit/helpers/*_test.rb']
    t.libs          << "test"
    t.rcov_opts     =  rcov_options
    t.verbose       =  true
  end

  task :clean do
    rm_f "coverage/coverage.data" if File.exist?("tmp/coverage.data")
  end

  desc "Run cucumber & test to generate aggregated coverage"
  task :all => :clean do
    ["tests","cucumber"].each{ |task| Rake::Task["rcov:#{task}"].invoke }
  end
end