module Withings
  # Custom errors for rescuing from Withings API errors
  class Error < StandardError
    # @return [Integer]
    attr_reader :code

    # Raised when client is misconfigured
    ClientConfigurationError = Class.new(self)
  end
end
