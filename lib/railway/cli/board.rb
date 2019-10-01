# frozen_string_literal: true

class Railway
  module CLI
    # Prints a table of rail services
    class Board
      def self.print(title, services, origin = false)
        print_title(title)
        print_header
        services.sort_by(&:st).each do |serv|
          stops = serv.calling_points.count.positive? ? serv.calling_points.count.to_s : '-'
          name  = origin ? serv.origin_name : serv.destination_name
          puts "| #{serv.st.ljust(5)} | #{serv.platform.to_s.ljust(4)} | #{stops.ljust(5)} |"\
               " #{name.to_s.ljust(37)} | #{serv.et.ljust(13)} |"
        end
        print_footer
      end

      def self.print_title(title)
        title  = title.upcase.gsub(/(.{1})(?=.)/, '\1 \2')
        offset = (80 - title.length) / 2.0
        puts "#{' ' * offset.floor}#{title}#{' ' * offset.ceil}"
      end

      private_class_method def self.print_header
        print_divider
        puts "| TIME  | PLAT | STOPS | NAME#{' ' * 34}| STATUS#{' ' * 8}|"
        print_divider
      end

      private_class_method def self.print_footer
        print_divider
      end

      private_class_method def self.print_divider
        puts "+#{'-' * 7}+#{'-' * 6}+#{'-' * 7}+#{'-' * 39}+#{'-' * 15}+"
      end
    end
  end
end
