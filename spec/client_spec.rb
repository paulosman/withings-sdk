require 'spec_helper'

describe Withings::Client do

  describe '#initialize' do
    context 'when no consumer secret is provided' do
      it 'raises an error' do
        expect { Withings::Client.new({ consumer_key: 'foo' }) }.to raise_error(ArgumentError)
      end
    end

    context 'when no consumer key is specified' do
      it 'raises an error' do
        expect { Withings::Client.new({ consumer_secret: 'foo' }) }.to raise_error(ArgumentError)
      end
    end

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
