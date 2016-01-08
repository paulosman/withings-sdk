require 'spec_helper'

describe WithingsSDK::HTTP::OAuthClient do
  subject do
    WithingsSDK::Client.new do |config|
      config.consumer_key = 'foo'
      config.consumer_secret = 'bar'
      config.token = 'secret'
      config.secret = 'super_secret'
    end
  end

  before do
    @consumer = spy('consumer')
    token = { oauth_token: 'token', oauth_token_secret: 'secret' }
    allow(@consumer).to receive(:authorize_url).and_return('http://foo.com/')
    allow(@consumer).to receive(:token_request).and_return(token)
    subject.consumer = @consumer
  end

  let (:opts) { Hash['foo', 'bar'] }

  context 'when generating a request token' do
    it 'forwards paramaters to oauth gem method' do
      subject.request_token(opts)
      expect(@consumer).to have_received(:get_request_token).with(opts)
    end
  end

  context 'when generating an authorize url' do
    it 'calls authorize_url on consumer' do
      subject.authorize_url('token', 'secret', opts)
      expect(@consumer).to have_received(:authorize_url)
    end
  end

  context 'when generating an access token' do
    it 'calls token_request on consumer' do
      token = spy('token')
      allow(token).to receive(:token).and_return 'foo'
      subject.access_token('token', 'secret', opts)
      expect(@consumer).to have_received(:token_request)
    end
  end
end
