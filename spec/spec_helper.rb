require 'webmock/rspec'

webmock_opts = {allow_localhost: true}

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
  webmock_opts[:allow] = 'codeclimate.com'
end

WebMock.disable_net_connect!(webmock_opts)

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'activite'

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
