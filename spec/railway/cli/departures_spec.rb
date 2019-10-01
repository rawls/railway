# frozen_string_literal: true

# rubocop:disable Layout/TrailingWhitespace

describe Railway::CLI::Departures do
  let(:railway) { Railway.new(ldbws: ldbws_cfg, station_yaml: test_stations_yaml) }
  let(:ldbws_cfg) { { token: 'abc-123' } }
  let(:test_stations_yaml) { fixtures_path + 'test_stations.yml' }

  describe '.print' do
    let(:crs) { 'LDS' }
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
      expect { described_class.print(railway, crs) }.to output(expected_output).to_stdout
    end
  end
end

# rubocop:enable Layout/TrailingWhitespace
