# frozen_string_literal: true

class Railway
  module LDBWS
    module Structs
      # Represents a railway service (departure or arrival)
      class Service
        attr_reader :origin, :origin_name, :destination, :destination_name, :st, :et, :operator, :operator_name
        attr_reader :service_type, :platform, :calling_points, :service_id

        # TODO: Parse times into Datetime objects (many ETDs are Strings like 'On time' or 'Cancelled')

        def self.from_xml(service)
          new(origin_name: service.xpath('./origin/location/locationName').text,
              origin: service.xpath('./origin/location/crs').text,
              destination_name: service.xpath('./destination/location/locationName').text,
              destination: service.xpath('./destination/location/crs').text,
              st: service.at('./sta') ? service.xpath('./sta').text : service.xpath('./std').text,
              et: service.at('./eta') ? service.xpath('./eta').text : service.xpath('./etd').text,
              operator_name: service.xpath('./operator').text,
              operator: service.xpath('./operatorCode').text,
              service_type: service.xpath('serviceType').text,
              platform: service.xpath('./platform').text,
              service_id: service.xpath('./serviceID').text,
              calling_points: CallingPoint.parse_xml(service.xpath('.//callingPointList')))
        end

        def initialize(opts = {})
          @origin_name      = opts[:origin_name]
          @origin           = opts[:origin]
          @destination_name = opts[:destination_name]
          @destination      = opts[:destination]
          @st               = opts[:st]
          @et               = opts[:et]
          @operator         = opts[:operator]
          @operator_name    = opts[:operator_name]
          @service_type     = opts[:service_type]
          @platform         = opts[:platform]
          @service_id       = opts[:service_id]
          @calling_points   = opts[:calling_points].map { |cp| CallingPoint.new(cp) }
        end

        def to_h
          {
            origin_name: @origin_name,
            origin: @origin,
            destination_name: @destination_name,
            destination: @destination,
            st: @st,
            et: @et,
            operator: @operator,
            operator_name: @operator_name,
            service_type: @service_type,
            platform: @platform,
            service_id: @service_id,
            calling_points: @calling_points.map(&:to_h)
          }
        end

        def ==(other)
          other.class == self.class && other.to_h == to_h
        end
        alias eql? ==

        def hash
          to_h.hash
        end
      end
    end
  end
end
