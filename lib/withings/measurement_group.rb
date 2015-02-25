require 'withings/measures'

module Withings
  class MeasurementGroup < Base
    # Types of body measurements collected by Withings devices and supported
    # by this gem. See http://oauth.withings.com/api/doc#api-Measure-get_measure
    # for details.
    TYPES = {
      1  => Withings::Measure::Weight,
      4  => Withings::Measure::Height,
      5  => Withings::Measure::FatFreeMass,
      6  => Withings::Measure::FatRatio,
      8  => Withings::Measure::FatMassWeight,
      11 => Withings::Measure::Pulse
    }

    # Create a new instance with a collection of measurements of the appropriate
    # Withings::Measure type.
    #
    # @param attrs [Hash]
    # @return [Withings::MeasurementGroup]
    def initialize(attrs = {})
      super(attrs)
      return if attrs['measures'].nil?
      @measures = attrs['measures'].collect do |measurement|
        klass = TYPES[measurement['type']]
        klass.new(measurement) unless klass.nil?
      end.reject { |obj| obj.nil? }
    end
  end
end
