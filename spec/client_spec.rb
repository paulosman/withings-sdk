require 'spec_helper'

describe Withings::Client do

  describe '#initialize' do
    context 'when an access token and secret are specified' do
      it 'should be connected' do
        client = Withings::Client.new({
          consumer_key: 'foo',
          consumer_secret: 'bar',
          token: 'token',
          secret: 'secret'
        })
        expect(client.connected?).to be true
      end
    end
    context 'when no access token or secret are specified' do
      describe '#consumer_key=' do
        it 'sets the consumer_key string' do
          subject.consumer_key = 'foo'
          expect(subject.consumer_key).to eq('foo')
        end
      end
      describe '#consumer_secret=' do
        it 'sets the consumer_secret string' do
          subject.consumer_secret = 'bar'
          expect(subject.consumer_secret).to eq('bar')
        end
      end
    end
  end
  
  describe '#user_agent' do
    it 'defaults to WithingsRubyGem/version' do
      expect(subject.user_agent).to eq("WithingsRubyGem/#{Withings::VERSION}")
    end
  end

  describe '#user_agent=' do
    it 'overwrites the User-Agent string' do
      subject.user_agent = 'MyWithingsClient/1.0.0'
      expect(subject.user_agent).to eq('MyWithingsClient/1.0.0')
    end
  end
  
  describe '#activities' do
    context 'when no consumer secret is provided' do
      it 'raises an error' do
        @client = Withings::Client.new({ consumer_key: 'foo' })
        expect { @client.activities(1234) }.to raise_error(Withings::Error::ClientConfigurationError)
      end
    end

    context 'when no consumer key is specified' do
      it 'raises an error' do
        @client = Withings::Client.new({ consumer_secret: 'foo' })
        expect { @client.activities(1234) }.to raise_error(Withings::Error::ClientConfigurationError)
      end
    end
  end
  
  context 'with an initialized client' do
    before do
      @client = Withings::Client.new do |config|
        config.consumer_key = 'foo'
        config.consumer_secret = 'bar'
      end
    end

    it 'has a consumer key' do
      expect(@client.consumer_key).not_to be nil
    end

    it 'has a consumer secret' do
      expect(@client.consumer_secret).not_to be nil
    end

  end
end
