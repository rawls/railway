# frozen_string_literal: true

class Railway
  module CLI
    # CLI command handler
    class Controller
      def self.handle(token, args)
        railway = Railway.new(ldbws: { token: token })
        command = args[0].downcase.gsub('-', '_')
        case command
        when 'arrivals', 'departures'
          handle_arrivals_departures(railway, args, command)
        when 'next_train'
          handle_next_train(railway, args)
        else
          abort "Unrecognised command: #{command}"
        end
      rescue Railway::LDBWSError => e
        puts "ERROR: #{e.message} (#{e.backtrace.first})\nRequest: #{e.request}\nResponse: #{e.response}"
      end

      private_class_method def self.handle_arrivals_departures(railway, args, command)
        crs  = args[1].upcase
        name = railway.station.name(crs)
        abort "Unknown station '#{crs}'" unless name
        Board.print(name, railway.send(command, crs), command == 'arrivals')
      end

      private_class_method def self.handle_next_train(railway, args)
        crs   = args[1].upcase
        dests = args[2].upcase.split(',')
        names = [*dests, crs].inject({}) do |hash, dest|
          hash.merge(dest => railway.station.name(dest))
        end
        abort 'Unknown station code provided' if names.values.include?(nil)
        Board.print_title("from #{names[crs]}")
        railway.next_train(crs, dests).each do |dest, services|
          Board.print("to #{names[dest]}", services)
        end
      end
    end
  end
end
