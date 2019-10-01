# frozen_string_literal: true

class Railway
  module CLI
    # Prints a table of rail services
    class Board
      def self.print_board(railway, crs, services)
        header(railway, crs)
        services.sort_by(&:st).each do |serv|
          stops = serv.calling_points.count.positive? ? serv.calling_points.count.to_s : '?'
          puts "| #{serv.st.ljust(5)} | #{serv.platform.to_s.ljust(4)} | #{stops.ljust(5)} |"\
                 " #{serv.destination_name.to_s.ljust(37)} | #{serv.et.ljust(13)} |"
        end
        footer
      end

      def self.header(railway, crs)
        station = railway.station.find(crs)
        abort "Station not found for: #{crs}" unless station
        title = station[:name].upcase.gsub(/(.{1})(?=.)/, '\1 \2')
        offset = (80 - title.length) / 2.0
        puts "#{' ' * offset.floor}#{title}#{' ' * offset.ceil}"
        puts divider
        puts "| TIME  | PLAT | STOPS | NAME#{' ' * 34}| STATUS#{' ' * 8}|"
        puts divider
      end

      def self.footer
        puts divider
      end

      def self.divider
        "+#{'-' * 7}+#{'-' * 6}+#{'-' * 7}+#{'-' * 39}+#{'-' * 15}+"
      end
    end
  end
end
