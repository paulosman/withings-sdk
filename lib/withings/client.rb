require 'withings/error'
require 'withings/http/request'

require 'withings/activity'

module Withings
  class Client
    include Withings::HTTP::OAuthClient

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
    #   client = Withings::Client.new({ consumer_key: your_key, consumer_secret: your_secret })
    #
    # @example User has authorized access to their Withings account
    #   client = Withings::Client.new({
    #     consumer_key: your_key,
    #     consumer_secret: your_secret,
    #     token: your_access_token,
    #     secret: your_access_token_secret
    #   })
    #
    # @example You can also pass parameters as a block
    #   client = Withings::Client.new do |config|
    #     config.consumer_key = your_key
    #     config.consumer_secret = your_secret
    #     config.token = token
    #     config.secret = secret
    #   end
    #
    # @return [Withings::Client]
    def initialize(options = {})
      @options ||= DEFAULT_OPTIONS.dup
      @options.merge!(options)

      @options.each do |key, value|
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
      @user_agent ||= "WithingsRubyGem/#{Withings::VERSION}"
    end

    # Get a list of activity measures for the specified user
    #
    # @param user_id [Integer]
    # @param options [Hash]
    #
    # @return [Array<Withings::Activity>]
    def activities(user_id, options = {})
      perform_request(:get, '/v2/measure', Withings::Activity, 'activities', {
        action: 'getactivity',
        userid: user_id
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
        raise Withings::Error::ClientConfigurationError, "Missing consumer_key or consumer_secret"
      end
      options = Withings::Utils.normalize_date_params(options)
      request = Withings::HTTP::Request.new(@access_token, { 'User-Agent' => user_agent })
      response = request.send(http_method, path, options)
      if response.has_key? key
        response[key].collect do |element|
          klass.new(element)
        end
      else
        [klass.new(response)]
      end
    end
  end
end
