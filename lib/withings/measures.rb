module Withings
  class Measure < Base

    # Create a new instance.
    #
    # The Withings API returns all values as integers with a unit which represents
    # the power of 10 the value should be multiplied by to get the real value. For
    # example, value=20 and unit=-1 should be 2.0.
    #
    # @param attrs [Hash]
    # @return [Withings::Measure]
    def initialize(attrs = {})
      super(attrs)
      @value = value / (10 ** unit.abs).to_f
    end

    #
    # Different measurement types
    #
    
    Weight = Class.new(self) do |cls|
      # Return weight measurement in kilograms (default unit)
      #
      # @return [Float]
      def in_kg
        @value
      end

      # Return weight measurement in pounds
      #
      # @return [Float]
      def in_lb
        (@value * 2.20462).round(3)
      end
    end
    
    Height = Class.new(self)
    Pulse  = Class.new(self)

    FatFreeMass   = Class.new(Weight)
    FatMassWeight = Class.new(Weight)
    FatRatio      = Class.new(self)
  end
end
