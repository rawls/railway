# frozen_string_literal: true

require_relative 'railway/errors'
require_relative 'railway/station'
require_relative 'railway/ldbws'
require_relative 'railway/cli'

# Provides information about UK railway services
class Railway
  attr_reader :station, :ldbws

  def initialize(opts = {})
    @station = Station.new(station_yaml: opts[:station_yaml])
    @ldbws   = LDBWS::Client.new(opts[:ldbws] || {})
  end

  # Returns an array of train services that are departing soon from the specified station
  def departures(station, opts = {})
    ldbws.dep_board_with_details(station, opts)
  end

  # Returns an array of train services that are arriving soon at the specified station
  def arrivals(station, opts = {})
    ldbws.arrival_board(station, opts)
  end

  # Returns a hash of the next train departing from the specified station and calling at each of the provided
  # destinations
  def next_train(station, destinations, opts = {})
    ldbws.next_departures_with_details(station, destinations, opts)
  end
end
