# frozen_string_literal: true

class Railway
  class RailwayError < StandardError; end
  class LDBWSError < RailwayError; end

  # Stores request and response in the case of a SOAP fault
  class SoapFault < LDBWSError
    attr_reader :request, :response

    def initialize(message, request = nil, response = nil)
      @request  = request
      @response = response
      super(message)
    end
  end
end
