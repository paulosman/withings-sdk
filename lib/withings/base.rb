module Withings
  class Base
    # @return [Hash]
    attr_reader :attrs

    # Initializes a new object with attributes for the values passed to the constructor.
    #
    # @param attrs [Hash]
    # @return [Withings::Base]
    def initialize(attrs = {})
      @attrs = attrs || {}
      @attrs.each do |key, value|
        self.class.class_eval { attr_reader key }
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
