# frozen_string_literal: true

class Railway
  class RailwayError < StandardError; end
  # Stores request and response if relevant
  class LDBWSError < RailwayError
    attr_reader :request, :response

    def initialize(message, request = nil, response = nil)
      @request  = request
      @response = response
      super(message)
    end
  end

  class SoapFault < LDBWSError; end
end
