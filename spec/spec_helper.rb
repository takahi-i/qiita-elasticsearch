if ENV["CI"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require File.expand_path("../qiita/elasticsearch/spec_helper", __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.warnings = true
end
