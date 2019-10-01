# frozen_string_literal: true

class Railway
  module CLI
    # Prints departure information for a station
    class Arrivals < Board
      def self.print(railway, crs)
        services = railway.arrivals(crs)
        print_board(railway, crs, services)
      end
    end
  end
end
