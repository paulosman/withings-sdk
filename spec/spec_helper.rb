require 'webmock/rspec'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
  WebMock.disable_net_connect!(:allow => "codeclimate.com")
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'withings'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
