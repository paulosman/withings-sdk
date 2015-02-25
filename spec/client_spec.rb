require 'spec_helper'

describe Withings::Client do

  let (:configured_client) do
    Withings::Client.new do |config|
      config.consumer_key = 'foo'
      config.consumer_secret = 'bar'
      config.token = 'secret'
      config.secret = 'super_secret'
    end
  end

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
    context 'when client is correctly configured' do
      before do
        stub_request(:get, /.*wbsapi.*/).
          with(query: hash_including({action: 'getactivity'})).
          to_return(body: '{"status":0,"body":{"activities":[{"date":"foo"}]}}')
      end

      let (:user_id) { 123 }
      let (:opts) { Hash['date', '2012-01-01'] }

      it 'should return an array of activities' do
        expect(configured_client.activities(user_id, opts)).to be_an Array
        expect(configured_client.activities(user_id, opts).first).to be_an Withings::Activity
      end
    end
  end

  describe '#body_measurements' do
    let (:user_id) { 123 }
    let (:opts) { Hash['startdate', '2012-01-01', 'enddate', '2013-01-01'] }
    let (:results) { configured_client.body_measurements(user_id, opts) }

    before do
      stub_request(:get, /.*wbsapi.*/).
        with(query: hash_including({action: 'getmeas'})).
        to_return(body: '{"status":0,"body":{"updatetime":123,"measuregrps":[{"grpid":123,"measures":[{"type":11,"value":70,"unit":0},{"type":1,"value":87839,"unit":-3}]}]}}')
    end

    it 'should return an array of measurement groups' do
      expect(results).to be_an Array
      expect(results.first).to be_an Withings::MeasurementGroup
    end

    context 'each measurement group' do
      it 'should contain measurements of the correct type' do
        expect(results.first.measures[0]).to be_an Withings::Measure::Pulse
        expect(results.first.measures[1]).to be_an Withings::Measure::Weight
      end

      it 'should normalize the values as floats' do
        expect(results.first.measures[0].value).to eq(70.0)
        expect(results.first.measures[1].value).to eq(87.839)
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
