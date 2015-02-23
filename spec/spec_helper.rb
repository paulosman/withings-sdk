require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'webmock/rspec'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'withings'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
