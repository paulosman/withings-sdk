require 'uri'
require 'json'
require 'net/http'

module WithingsSDK
  module HTTP
    BASE_URI = 'https://wbsapi.withings.net'

    class Request
      def initialize(access_token, headers)
        @access_token = access_token
        @headers = headers
      end

      def get(path, options = {})
        request(:get, path, options)
      end

      def post(path, options = {})
        request(:post, path, options)
      end

      protected

      def hash_to_query(hash)
        return URI.encode(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
      end

      def request_with_body(method, path, options = {})
        body = hash_to_query(options)
        uri  = "#{BASE_URI}#{path}"
        @access_token.send(method, uri, body, @headers)
      end

      def request_with_query_string(method, path, options = {})
        uri = "#{BASE_URI}#{path}?#{hash_to_query(options)}"
        @access_token.send(method, uri, @headers)
      end

      def request(method, path, options = {})
        if [:post, :put].include? method
          response = request_with_body(method, path, options)
        else
          response = request_with_query_string(method, path, options)
        end

        if response.code.to_i < 200 or response.code.to_i >= 400
          raise WithingsSDK::Error::ClientConfigurationError, response.body
        end

        body = JSON.parse(response.body)
        if body['status'].to_i != 0
          raise WithingsSDK::Error::InvalidResponseError, "#{body['status']} - #{body['error']}"
        end

        body['body'] ||= body
        body['body']
      end
    end
  end
end
