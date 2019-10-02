# frozen_string_literal: true

class Railway
  module LDBWS
    module Structs
      # A station stop for a service
      class CallingPoint
        attr_reader :station, :station_name, :st, :et, :length
        def self.from_xml(xml)
          parse_xml(xml).map { |cp_hash| new(cp_hash) }
        end

        def self.parse_xml(xml)
          xml.xpath('./callingPoint').map do |cp|
            length = cp.xpath('./length').text
            {
              station_name: cp.xpath('./locationName').text,
              station: cp.xpath('./crs').text,
              st: cp.xpath('./st').text,
              et: cp.xpath('./et').text,
              length: (length.nil? || length.empty? ? nil : length.to_i)
            }
          end
        end

        def initialize(opts = {})
          @station      = opts[:station]
          @station_name = opts[:station_name]
          @st           = opts[:st]
          @et           = opts[:et]
          @length       = opts[:length]
        end

        def to_h
          {
            station: @station,
            station_name: @station_name,
            st: @st,
            et: @et,
            length: @length
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
