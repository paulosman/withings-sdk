require 'oauth'

module Withings
  module HTTP
    module OAuthClient
      attr_accessor :consumer_key, :consumer_secret, :token, :secret

      DEFAULT_OPTIONS = {
        site:              'https://oauth.withings.com',
        proxy:              nil,
        request_token_path: '/account/request_token',
        authorize_path:     '/account/authorize',
        access_token_path:  '/account/access_token'
      }
    
      @options = {}

      def request_token(options = {})
        consumer.get_request_token(options)
      end

      def authorize_url(token, secret, options = {})
        request_token = OAuth::RequestToken.new(consumer, token, secret)
        request_token.authorize_url(options)
      end

      def access_token(token, secret, options = {})
        request_token = OAuth::RequestToken.new(consumer, token, secret)
        @access_token = request_token.get_access_token(options)
        @token = @access_token.token
        @secret = @access_token.secret
        @access_token
      end

      def existing_access_token(token, secret)
        OAuth::AccessToken.new(consumer, token, secret)
      end
      
      def connected?
        !@access_token.nil?
      end

      private
      
      def consumer
        @options[:scheme] = :query_string
        @consumer ||= OAuth::Consumer.new(@consumer_key, @consumer_secret, @options)
      end
    end
  end
end
