module WithingsSDK

  # A Response is used to represent an empty API response with a status
  # code and no additional information.
  class Response
    # @return [Integer]
    attr_reader :status

    def initialize(attrs = {})
      @status = attrs['status'].to_i if attrs.has_key? 'status'
    end
  end
end
