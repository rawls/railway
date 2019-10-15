# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'nokogiri'
require 'logger'

class Railway
  module LDBWS
    # Client for interfacing with the OpenLDBWS SOAP API
    class Client
      DEFAULT_ENDPOINT = 'https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb11.asmx'
      DEFAULT_TIMEOUT  = 15 # seconds
      NAMESPACES = {
        'xmlns:soap' => 'http://www.w3.org/2003/05/soap-envelope',
        'xmlns:typ' => 'http://thalesgroup.com/RTTI/2013-11-28/Token/types',
        'xmlns:ldb' => 'http://thalesgroup.com/RTTI/2017-10-01/ldb/'
      }.freeze
      ACTIONS = {
        'GetArrivalBoard' => 'http://thalesgroup.com/RTTI/2012-01-13/ldb/GetArrivalBoard',
        'GetDepBoardWithDetails' => 'http://thalesgroup.com/RTTI/2015-05-14/ldb/GetDepBoardWithDetails',
        'GetNextDeparturesWithDetails' => 'http://thalesgroup.com/RTTI/2015-05-14/ldb/GetNextDeparturesWithDetails'
      }.freeze

      attr_accessor :log

      def initialize(opts = {})
        @log      = opts[:logging] == true ? Logger.new(STDOUT) : Logger.new(nil)
        @token    = opts[:token] || raise(LDBWSError, 'Please specify an access :token')
        @endpoint = URI.parse(opts[:endpoint] || DEFAULT_ENDPOINT)
        @timeout  = opts[:timeout] || DEFAULT_TIMEOUT
      end

      # Sends a GetDepBoardWithDetails request and returns the result or raises an error
      def dep_board_with_details(crs, opts = {})
        request_station_board('GetDepBoardWithDetails', crs, opts)
      end

      # Sends a GetDepBoardWithDetails request and returns the result or raises an error
      def arrival_board(crs, opts = {})
        request_station_board('GetArrivalBoard', crs, opts)
      end

      # When provided with a starting station and a list of destinations it will return a list
      # of trains leaving from the starting station to those destinations
      def next_departures_with_details(origin, destinations, opts = {})
        name   = 'GetNextDeparturesWithDetails'
        action = ACTIONS[name]
        body   = soap_envelope(@token) do |xml|
          xml['ldb'].send("#{name}Request") do
            xml['ldb'].crs(origin)
            xml['ldb'].filterList do
              [destinations].flatten(1).each { |destination| xml['ldb'].crs(destination) }
            end
            xml['ldb'].timeOffset(opts[:time_offset]) if opts[:time_offset]
            xml['ldb'].timeWindow(opts[:time_window]) if opts[:time_window]
          end
        end
        response = send_request(action, body)
        destinations = response.xpath("/Envelope/Body/#{name}Response/DeparturesBoard/departures/destination")
        departures = {}
        destinations.each do |destination|
          crs = destination.xpath('./@crs').text
          services = remove_nils(destination.xpath('./service'))
          departures[crs] = services.map { |service| Structs::Service.from_xml(service) }
        end
        departures
      end

      def service_details(service_id)
        name   = 'GetServiceDetails'
        action = ACTIONS[name]
        body   = soap_envelope(@token) do |xml|
          xml['ldb'].send("#{name}Request") { xml['ldb'].serviceID(service_id) }
        end
        response    = send_request(action, body)
        #service_xml = response.xpath("/Envelope/Body/#{name}Response/GetServiceDetailsResult")
        #service     = Structs::Service.from_xml(service_xml) # TODO: FIXME
      end

      private

      # Many of the API requests follow a similar structure. You send the same set of params and receive a station board
      # result. This method DRYs up those request types when provided with params and a soap action.
      def request_station_board(name, crs, opts)
        body = soap_envelope(@token) do |xml|
          xml['ldb'].send("#{name}Request") do
            xml['ldb'].crs(crs)
            xml['ldb'].numRows(opts[:num_rows] || 10)
            xml['ldb'].filterCrs(opts[:filter_crs])   if opts[:filter_crs] # TODO: I think this is an array
            xml['ldb'].filterType(opts[:filter_type]) if opts[:filter_type]
            xml['ldb'].timeOffset(opts[:time_offset]) if opts[:time_offset]
            xml['ldb'].timeWindow(opts[:time_window]) if opts[:time_window]
          end
        end
        response = send_request(ACTIONS[name], body)
        services = response.xpath("/Envelope/Body/#{name}Response/GetStationBoardResult/trainServices/service")
        services.map { |service| Structs::Service.from_xml(service) }
      end

      # Builds the soap envelope wrapper for a request
      def soap_envelope(token, &block)
        Nokogiri::XML::Builder.new do |xml|
          xml.Envelope(NAMESPACES) do
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml['soap'].Header { xml['typ'].AccessToken { xml['typ'].TokenValue(token) } }
            xml['soap'].Body(&block)
          end
        end.to_xml
      end

      # Puts a SOAP request on the socket and parses the response XML
      def send_request(soap_action, request)
        log.debug "Sending #{soap_action} request:"
        request.to_s.split("\n").each { |line| log.debug(line) }
        http = Net::HTTP.new(@endpoint.host, @endpoint.port)
        http.read_timeout = @timeout
        http.use_ssl = @endpoint.scheme == 'https'
        headers = { 'SOAPAction' => soap_action, 'Content-Type' => 'text/xml;charset=utf-8' }
        response = http.post(@endpoint.request_uri, request, headers)
        log.debug "Received #{response&.code} response:"
        response.body.to_s.split("\n").each { |line| log.debug(line) }
        return handle_fault(request, response) if response.body =~ /soap:Fault/

        # TODO: additional error handling for non-200s and non-parsables
        Nokogiri::XML(response.body).remove_namespaces!
      end

      # Removes annoying xsi:nil="true" elements from an array of xml elements
      def remove_nils(xml)
        xml.reject { |obj| obj.attribute('nil')&.value == 'true' }
      end

      # Extracts the message from a soap fault and raises an exception
      def handle_fault(request, response)
        xml = Nokogiri::XML(response.body)
        msg = xml.xpath('/soap:Envelope/soap:Body/soap:Fault/soap:Reason/soap:Text').text
        raise SoapFault.new("Error from server: #{msg}", request, response)
      end
    end
  end
end
