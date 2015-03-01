require 'activite/measures'

module Activite
  class MeasurementGroup < Base
    # Types of body measurements collected by Withings devices and supported
    # by this gem. See http://oauth.withings.com/api/doc#api-Measure-get_measure
    # for details.
    TYPES = {
      1  => Activite::Measure::Weight,
      4  => Activite::Measure::Height,
      5  => Activite::Measure::FatFreeMass,
      6  => Activite::Measure::FatRatio,
      8  => Activite::Measure::FatMassWeight,
      11 => Activite::Measure::Pulse
    }

    # Create a new instance with a collection of measurements of the appropriate
    # Activite::Measure type.
    #
    # @param attrs [Hash]
    # @return [Activite::MeasurementGroup]
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
