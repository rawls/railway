# frozen_string_literal: true

# rubocop:disable Layout/TrailingWhitespace

describe Railway::CLI::Arrivals do
  let(:railway) { Railway.new(ldbws: ldbws_cfg, station_yaml: test_stations_yaml) }
  let(:ldbws_cfg) { { token: 'abc-123' } }
  let(:test_stations_yaml) { fixtures_path + 'test_stations.yml' }

  describe '.print' do
    let(:crs) { 'FNN' }
    let(:expected_output) do
      <<~TABLE
                               F A R N B O R O U G H   N O R T H                        
        +-------+------+-------+---------------------------------------+---------------+
        | TIME  | PLAT | STOPS | NAME                                  | STATUS        |
        +-------+------+-------+---------------------------------------+---------------+
        | 10:29 | 1    | ?     | Redhill                               | On time       |
        | 10:32 | 2    | ?     | Reading                               | 10:37         |
        | 11:26 | 2    | ?     | Reading                               | 11:36         |
        | 11:29 | 1    | ?     | Redhill                               | On time       |
        +-------+------+-------+---------------------------------------+---------------+
      TABLE
    end

    it 'prints a table' do
      expect { described_class.print(railway, crs) }.to output(expected_output).to_stdout
    end
  end
end

# rubocop:enable Layout/TrailingWhitespace
