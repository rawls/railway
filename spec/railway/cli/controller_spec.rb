# frozen_string_literal: true

# rubocop:disable Layout/TrailingWhitespace

# TODO: Should use the test station list rather than the production one
describe Railway::CLI::Controller do
  subject(:result) { described_class.handle(token, args) }

  let(:token) { 'abc-123' }

  describe '.handle' do
    context 'when the command is arrivals' do
      let(:args) { %w[arrivals FNN] }
      let(:expected_output) do
        <<~TABLE
                                 F A R N B O R O U G H   N O R T H                        
          +-------+------+-------+---------------------------------------+---------------+
          | TIME  | PLAT | STOPS | NAME                                  | STATUS        |
          +-------+------+-------+---------------------------------------+---------------+
          | 10:29 | 1    | -     | Reading                               | On time       |
          | 10:32 | 2    | -     | Redhill                               | 10:37         |
          | 11:26 | 2    | -     | Redhill                               | 11:36         |
          | 11:29 | 1    | -     | Reading                               | On time       |
          +-------+------+-------+---------------------------------------+---------------+
        TABLE
      end

      it 'prints a table' do
        expect { result }.to output(expected_output).to_stdout
      end
    end

    context 'when the command is departures' do
      let(:args) { %w[departures LDS] }
      let(:expected_output) do
        <<~TABLE
                                             L E E D S                                    
          +-------+------+-------+---------------------------------------+---------------+
          | TIME  | PLAT | STOPS | NAME                                  | STATUS        |
          +-------+------+-------+---------------------------------------+---------------+
          | 09:48 | 11C  | 12    | Sheffield                             | 10:09         |
          | 10:03 | 5B   | 5     | Ilkley                                | On time       |
          | 10:06 | 8B   | 6     | Brighouse                             | On time       |
          | 10:06 | 16A  | 4     | Liverpool Lime Street                 | On time       |
          | 10:08 | 17B  | 10    | Nottingham                            | On time       |
          +-------+------+-------+---------------------------------------+---------------+
        TABLE
      end

      it 'prints a table' do
        expect { result }.to output(expected_output).to_stdout
      end
    end

    context 'when the command is next-train' do
      let(:args) { ['next-train', 'FNB', 'WAT,LDS'] }
      let(:expected_output) do
        <<~TABLE
                           F R O M   F A R N B O R O U G H   ( M A I N )                  
                                T O   L O N D O N   W A T E R L O O                       
          +-------+------+-------+---------------------------------------+---------------+
          | TIME  | PLAT | STOPS | NAME                                  | STATUS        |
          +-------+------+-------+---------------------------------------+---------------+
          | 13:45 | 1    | 6     | London Waterloo                       | On time       |
          +-------+------+-------+---------------------------------------+---------------+
                                          T O   L E E D S                                 
          +-------+------+-------+---------------------------------------+---------------+
          | TIME  | PLAT | STOPS | NAME                                  | STATUS        |
          +-------+------+-------+---------------------------------------+---------------+
          +-------+------+-------+---------------------------------------+---------------+
        TABLE
      end

      it 'prints a table' do
        expect { result }.to output(expected_output).to_stdout
      end
    end

    context 'when the command is unrecognised' do
      let(:args) { ['foobar'] }

      it 'aborts' do
        expect { expect { result }.to raise_error(SystemExit) }.to output("Unrecognised command: foobar\n").to_stderr
      end
    end
  end
end

# rubocop:enable Layout/TrailingWhitespace
