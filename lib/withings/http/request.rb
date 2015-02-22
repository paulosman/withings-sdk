require 'uri'
require 'json'
require 'net/http'

module Withings
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
        case response
        when Net::HTTPOK
          body = JSON.parse(response.body)
          if body['status'].to_i != 0
            # TODO
          end
          body['body']
        else
          raise Withings::Error::ClientConfigurationError, "Foo"
        end
      end
      
      protected

      def hash_to_query(hash)
        return URI.encode(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
      end
    end
  end
end
