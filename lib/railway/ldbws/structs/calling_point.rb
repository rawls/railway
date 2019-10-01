# frozen_string_literal: true

class Railway
  module LDBWS
    module Structs
      # A station stop for a service
      class CallingPoint
        attr_reader :station, :station_name, :st, :et, :length
        def self.from_xml(xml)
          xml.xpath('./callingPoint').map do |cp|
            length = cp.xpath('./length').text
            new(station_name: cp.xpath('./locationName').text,
                station: cp.xpath('./crs').text,
                st: cp.xpath('./st').text,
                et: cp.xpath('./et').text,
                length: (length.nil? || length.empty? ? nil : length.to_i))
          end
        end

        def initialize(opts = {})
          @station      = opts[:station]
          @station_name = opts[:station_name]
          @st           = opts[:st]
          @et           = opts[:et]
          @length       = opts[:length]
        end
      end
    end
  end
end
