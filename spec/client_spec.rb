require 'spec_helper'

describe Activite::Client do

  let (:configured_client) do
    Activite::Client.new do |config|
      config.consumer_key = 'foo'
      config.consumer_secret = 'bar'
      config.token = 'secret'
      config.secret = 'super_secret'
    end
  end

  describe '#initialize' do
    context 'when an access token and secret are specified' do
      it 'should be connected' do
        client = Activite::Client.new({
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
      expect(subject.user_agent).to eq("WithingsRubyGem/#{Activite::VERSION}")
    end
  end

  describe '#user_agent=' do
    it 'overwrites the User-Agent string' do
      subject.user_agent = 'MyWithingsClient/1.0.0'
      expect(subject.user_agent).to eq('MyWithingsClient/1.0.0')
    end
  end
  
  describe '#activities' do
    let (:user_id) { 123 }
    let (:opts) { Hash['date', '2012-01-01'] }

    context 'when no consumer secret is provided' do
      it 'raises an error' do
        @client = Activite::Client.new({ consumer_key: 'foo' })
        expect { @client.activities(user_id) }.to raise_error(Activite::Error::ClientConfigurationError)
      end
    end

    context 'when no consumer key is specified' do
      it 'raises an error' do
        @client = Activite::Client.new({ consumer_secret: 'foo' })
        expect { @client.activities(user_id) }.to raise_error(Activite::Error::ClientConfigurationError)
      end
    end

    context 'when client is correctly configured' do
      let (:results) { configured_client.activities(user_id, opts) }

      before do
        stub_request(:get, /.*wbsapi.*/).
          with(query: hash_including({action: 'getactivity'})).
          to_return(body: fixture('activities.json'))
      end

      it 'should return an array of activities' do
        expect(results).to be_an Array
        expect(results.first).to be_a Activite::Activity
      end

      context 'when one result is returned (a single day)' do
        before do
          stub_request(:get, /.*wbsapi.*/).
            to_return(body: fixture('activity_single_day.json'))
        end

        it 'should return an array with one single activity' do
          expect(results).to be_an Array
          expect(results.length).to eq(1)
          expect(results.first).to be_an Activite::Activity
        end
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
        to_return(body: fixture('body_measurements.json'))
    end

    it 'should return an array of measurement groups' do
      expect(results).to be_an Array
      expect(results.first).to be_an Activite::MeasurementGroup
    end

    context 'each measurement group' do
      it 'should contain measurements of the correct type' do
        expect(results.first.measures[0]).to be_an Activite::Measure::Pulse
        expect(results.first.measures[1]).to be_an Activite::Measure::Weight
      end

      it 'should normalize the values as floats' do
        expect(results.first.measures[0].value).to eq(70.0)
        expect(results.first.measures[1].value).to eq(87.839)
      end
    end
  end

  describe '#sleep_series' do
    let (:user_id) { 123 }
    let (:opts) { Hash['startdate', '2012-01-01', 'enddate', '2013-01-01'] }
    let (:results) { configured_client.sleep_series(user_id, opts) }

    before do
      stub_request(:get, /.*wbsapi.*/).
        with(query: hash_including({action: 'get'})).
        to_return(body: fixture('sleep_series.json'))
    end

    context 'with properly configured client' do
      it 'should return an array of Activite::SleepSeries objects' do
        expect(results).to be_an Array
        expect(results.length).to eq(2)
        expect(results[0]).to be_a Activite::SleepSeries
      end
    end
  end

  describe '#sleep_summary' do
    let (:user_id) { 123 }

    let (:opts) { Hash['startdate', '2012-01-01', 'enddate', '2013-01-01'] }
    let (:results) { configured_client.sleep_summary(user_id, opts) }

    before do
      stub_request(:get, /.*wbsapi.*/).
        with(query: hash_including({action: 'getsummary'})).
        to_return(body: fixture('sleep_summary.json'))
    end

    context 'with properly configured client' do
      it 'should return an array of Activite::SleepSummary objects' do
        expect(results.first).to be_a Activite::SleepSummary
      end
    end
  end

  describe 'Notifications' do
    let (:user_id) { 123 }
    let (:opts) { Hash['callbackurl', 'http://example.com', 'comment', 'foo']}

    describe '#create_notification' do
      let (:result) { configured_client.create_notification(user_id, opts) }

      before do
        stub_request(:post, /.*wbsapi.*/).
          with(body: hash_including({action: 'subscribe'})).
          to_return(body: fixture('empty_successful_response.json'))
      end

      context 'with properly configured client' do
        it 'should return a single Activite::Response object' do
          expect(result).to be_a Activite::Response
        end
        it 'should have status 0' do
          expect(result.status).to equal(0)
        end
      end
    end

    describe '#list_notifications' do
      let (:result) { configured_client.list_notifications(user_id) }

      before do
        stub_request(:get, /.*wbsapi.*/).
          with(query: hash_including({action: 'list'})).
          to_return(body: fixture('notifications.json'))
      end

      context 'with properly configured client' do
        it 'should return an array of Activite::Notification objects' do
          expect(result.first).to be_a Activite::Notification
        end
      end
    end

    describe '#revoke_notification' do
      let (:result) { configured_client.revoke_notification(user_id, opts) }

      before do
        stub_request(:get, /.*wbsapi.*/).
          with(query: hash_including({action: 'revoke'})).
          to_return(body: fixture('empty_successful_response.json'))
      end

      context 'with properly configured client' do
        it 'should return a single Activite::Response object' do
          expect(result).to be_a Activite::Response
        end
        it 'should have status 0' do
          expect(result.status).to equal(0)
        end
      end
    end
  end

  context 'with an initialized client' do
    before do
      @client = Activite::Client.new do |config|
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
