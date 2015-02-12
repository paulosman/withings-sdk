require "withings/version"

module Withings
  class Client

    # Initializes a new Client object
    #
    # @param options [Hash]
    # @return [Withings::Client]
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      yield(self) if block_given?
    end
  end
end
