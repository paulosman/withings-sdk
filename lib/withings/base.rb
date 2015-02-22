module Withings
  class Base
    # @return [Hash]
    attr_reader :attrs

    def initialize(attrs = {})
      @attrs = attrs || {}
    end
  end
end
