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

      if @consumer_key.nil? || @consumer_secret.nil?
        raise ArgumentError, "Missing consumer_key or consumer_secret"
      end
    end

    # Return the User-Agent string
    #
    # @return [String]
    def user_agent
      @user_agent ||= "WithingsRubyGem/#{Withings::VERSION}"
    end

    # Get a list of activity measures for the registered user
    def activity_measures(user_id, date, options = {})
      opts = {
        action: 'getactivity',
        userid: user_id,
        date: date
      }.merge(options)
      response = Withings::HTTP::Request.new('GET', '/v2/measure', credentials, opts)
      results = []
      response.results.each do |result|
        results << Withings::ActivityMeasure.new(result.date, result.steps)
      end
      results
    end

  end
end
