require 'spec_helper'

describe WithingsSDK::HTTP::Request do
  subject do
    consumer = OAuth::Consumer.new('key', 'secret')
    token = OAuth::AccessToken.new(consumer, 'foo', 'bar')
    WithingsSDK::HTTP::Request.new(token, {})
  end

  context 'when an API error is returned' do
    before do
      stub_request(:get, /.*wbsapi.*/).
        to_return(body: '{"status":1,"error":"the bad happened"}')
    end
    it 'should raise an error' do
      expect { subject.get('/foo') }.to raise_error(WithingsSDK::Error::InvalidResponseError)
    end
  end

  context 'when a non-200 response is returned' do
    before do
      class OAuth::AccessToken
        def get(path, options = {})
          return Struct.new(:code, :body).new(500, '')
        end
      end
    end
    it 'should raise an error' do
      expect { subject.get('/foo') }.to raise_error(WithingsSDK::Error::ClientConfigurationError)
    end
  end
end
