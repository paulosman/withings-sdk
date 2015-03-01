require 'uri'
require 'json'
require 'net/http'

module Activite
  module HTTP
    BASE_URI = 'https://wbsapi.withings.net'

    class Request
      def initialize(access_token, headers)
        @access_token = access_token
        @headers = headers
      end

      def get(path, options = {})
        uri = "#{BASE_URI}#{path}?#{hash_to_query(options)}"
        response = @access_token.get(uri, @headers)
        if response.code.to_i < 200 or response.code.to_i >= 400
          raise Activite::Error::ClientConfigurationError, response.body
        end
        body = JSON.parse(response.body)
        if body['status'].to_i != 0
          raise Activite::Error::InvalidResponseError, "#{body['status']} - #{body['error']}"
        end
        body['body']
      end
      
      protected

      def hash_to_query(hash)
        return URI.encode(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
      end
    end
  end
end
