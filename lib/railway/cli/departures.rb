# frozen_string_literal: true

class Railway
  module CLI
    # Prints departure information for a station
    class Departures < Board
      def self.print(railway, crs)
        services = railway.departures(crs)
        print_board(railway, crs, services)
      end
    end
  end
end
