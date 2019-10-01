# frozen_string_literal: true

require 'yaml'
require 'pathname'

class Railway
  # Information about UK railway stations.
  class Station
    STATION_YAML_DEFAULT = Pathname.new(__FILE__).realpath.parent.parent.parent + 'config' + 'stations.yml'

    def initialize(opts = {})
      yaml_path = opts[:station_yaml] || STATION_YAML_DEFAULT
      @stations = YAML.load_file(yaml_path.to_s).freeze
    end

    # Returns a hash of information about the specified station
    def find(crs)
      @stations[crs]
    end

    # Finds a station by its name
    def find_by_name(name)
      @stations.select { |_key, value| value[:name].match?(/#{name}/i) }
    end

    # Returns the station name for the provided CRS code
    def name(crs)
      @stations[crs][:name]
    rescue StandardError
      nil
    end

    # Returns all stations
    def all
      @stations
    end
  end
end
