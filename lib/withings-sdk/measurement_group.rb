require 'withings-sdk/measures'

module WithingsSDK
  class MeasurementGroup < Base
    # Types of body measurements collected by Withings devices and supported
    # by this gem. See http://oauth.withings.com/api/doc#api-Measure-get_measure
    # for details.
    TYPES = {
      1  => WithingsSDK::Measure::Weight,
      4  => WithingsSDK::Measure::Height,
      5  => WithingsSDK::Measure::FatFreeMass,
      6  => WithingsSDK::Measure::FatRatio,
      8  => WithingsSDK::Measure::FatMassWeight,
      11 => WithingsSDK::Measure::Pulse
    }

    # Create a new instance with a collection of measurements of the appropriate
    # WithingsSDK::Measure type.
    #
    # @param attrs [Hash]
    # @return [WithingsSDK::MeasurementGroup]
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
