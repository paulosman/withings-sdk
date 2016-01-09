require 'withings-sdk/error'
require 'withings-sdk/http/request'
require 'withings-sdk/activity'
require 'withings-sdk/measurement_group'
require 'withings-sdk/notification'
require 'withings-sdk/sleep_series'
require 'withings-sdk/sleep_summary'
require 'withings-sdk/response'

module WithingsSDK
  class Client
    include WithingsSDK::HTTP::OAuthClient

    attr_writer :user_agent

    # Initializes a new Client object used to communicate with the Withings API.
    #
    # An authenticated Client can be created with an access token and access token
    # secret if the user has previously authorized access to their Withings account
    # and you've stored their access credentials. An unauthenticated Client can be
    # created that will allow you to initiate the OAuth authorization flow, directing
    # the user to Withings to authorize access to their account.
    #
    # @param options [Hash]
    # @option options [String] :consumer_key The consumer key (required)
    # @option options [String] :consumer_secret The consumer secret (required)
    # @option options [String] :token The access token (if you've stored it)
    # @option options [String] :secret The access token secret (if you've stored it)
    #
    # @example User has not yet authorized access to their Withings account
    #   client = WithingsSDK::Client.new({ consumer_key: your_key, consumer_secret: your_secret })
    #
    # @example User has authorized access to their Withings account
    #   client = WithingsSDK::Client.new({
    #     consumer_key: your_key,
    #     consumer_secret: your_secret,
    #     token: your_access_token,
    #     secret: your_access_token_secret
    #   })
    #
    # @example You can also pass parameters as a block
    #   client = WithingsSDK::Client.new do |config|
    #     config.consumer_key = your_key
    #     config.consumer_secret = your_secret
    #     config.token = token
    #     config.secret = secret
    #   end
    #
    # @return [WithingsSDK::Client]
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      yield(self) if block_given?

      unless @token.nil? || @secret.nil?
        @access_token = existing_access_token(@token, @secret)
      end
    end

    # Return the User-Agent string
    #
    # @return [String]
    def user_agent
      @user_agent ||= "WithingsRubyGem/#{WithingsSDK::VERSION}"
    end

    # Get a list of activity measures for the specified user
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [Array<WithingsSDK::Activity>]
    def activities(user_id, options = {})
      perform_request(:get, '/v2/measure', WithingsSDK::Activity, 'activities', {
        action: 'getactivity',
        userid: user_id
      }.merge(options))
    end

    # Get a list of body measurements taken by Withings devices
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [Array<WithingsSDK::MeasurementGroup>]
    def body_measurements(user_id, options = {})
      perform_request(:get, '/measure', WithingsSDK::MeasurementGroup, 'measuregrps', {
        action: 'getmeas',
        userid: user_id
      }.merge(options))
    end

    # Return a list of weight body measurements
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [Array<WithingsSDK::Measure::Weight>]
    def weight(user_id, options = {})
      groups = body_measurements(user_id, options)
      groups.map do |group|
        group.measures.select { |m| m.is_a? WithingsSDK::Measure::Weight }.map do |m|
          WithingsSDK::Measure::Weight.new(m.attrs.merge('weighed_at' => group.date))
        end
      end.flatten
    end

    # Get details about a user's sleep
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [Array<WithingsSDK::Sleep>]
    def sleep_series(user_id, options = {})
      perform_request(:get, '/v2/sleep', WithingsSDK::SleepSeries, 'series', {
        action: 'get',
        userid: user_id
      }.merge(options))
    end

    # Get a summary of a user's night. Includes the total time they slept,
    # how long it took them to fall asleep, how long it took them to fall
    # asleep, etc.
    #
    # NOTE: user_id isn't actually used in this API call (so I assume it is
    # derived from the OAuth credentials) but I was uncomfortable introducing
    # this inconsistency into this gem.
    #
    # @param user_id [Intger]
    # @param options [Hash]
    #
    # @return [Array<WithingsSDK::SleepSummary>]
    def sleep_summary(user_id, options = {})
      perform_request(:get, '/v2/sleep', WithingsSDK::SleepSummary, 'series', {
        action: 'getsummary'
      }.merge(options))
    end

    # Register a webhook / notification with the Withings API. This allows
    # you to be notified when new data is available for a user.
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [WithingsSDK::Response]
    def create_notification(user_id, options = {})
      perform_request(:post, '/notify', WithingsSDK::Response, nil, {
        action: 'subscribe'
      }.merge(options))
    end

    # Get information about a specific webhook / notification.
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [WithingsSDK::Notification]
    def get_notification(user_id, options = {})
      perform_request(:get, '/notify', WithingsSDK::Notification, nil, {
        action: 'get'
      }.merge(options))
    end

    # Return a list of registered webhooks / notifications.
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [Array<WithingsSDK::Notification>]
    def list_notifications(user_id, options = {})
      perform_request(:get, '/notify', WithingsSDK::Notification, 'profiles', {
        action: 'list'
      }.merge(options))
    end

    # Revoke previously subscribed webhook / notification.
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [WithingsSDK::Response]
    def revoke_notification(user_id, options = {})
      perform_request(:get, '/notify', WithingsSDK::Response, nil, {
        action: 'revoke'
      }.merge(options))
    end

    private

    # Helper function that handles all API requests
    #
    # @param http_method [Symbol]
    # @param path [String]
    # @param klass [Class]
    # @param key [String]
    # @param options [Hash]
    #
    # @return [Array<Object>]
    def perform_request(http_method, path, klass, key, options = {})
      if @consumer_key.nil? || @consumer_secret.nil?
        raise WithingsSDK::Error::ClientConfigurationError, "Missing consumer_key or consumer_secret"
      end
      options = WithingsSDK::Utils.normalize_date_params(options)
      request = WithingsSDK::HTTP::Request.new(@access_token, { 'User-Agent' => user_agent })
      response = request.send(http_method, path, options)
      if key.nil?
        klass.new(response)
      elsif response.has_key? key
        response[key].collect do |element|
          klass.new(element)
        end
      else
        [klass.new(response)]
      end
    end
  end
end
