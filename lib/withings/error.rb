module Withings
  # Custom errors for rescuing from Withings API errors
  class Error < StandardError
    # @return [Integer]
    attr_reader :code

    # Raised when client is misconfigured
    ClientConfigurationError = Class.new(self)

    # Withings returns 200 for everything, making it difficult to figure out
    # exactly what went wrong. They also appear to send back fairly arbitrary
    # codes, for example a response with an HTTP Status Code 200 can contain
    # a body {"status":503,"error":"Invalid Params"} if OAuth credentials are
    # incorrect (503 normally indicates that a downstream service is unavailable).
    # Because of this we just wrap most errors in this class.
    InvalidResponseError = Class.new(self)
  end
end
