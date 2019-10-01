# frozen_string_literal: true

describe Railway::Station do
  subject(:station)        { described_class.new(station_yaml: test_stations_yaml) }

  let(:test_stations_yaml) { fixtures_path + 'test_stations.yml' }

  describe '#find' do
    subject(:result) { station.find(crs) }

    context 'when the station is listed' do
      let(:crs) { 'LDS' }

      it 'returns the station details' do
        expect(result[:name]).to eq('Leeds')
        expect(result[:longitude]).to eq(-1.5473)
        expect(result[:latitude]).to eq(53.7947)
      end
    end

    context 'when the station is not listed' do
      let(:crs) { 'XXX' }

      it 'returns nil if no station is found' do
        expect(result).to be_nil
      end
    end
  end

  describe '#find_by_name' do
    subject(:result) { station.find_by_name(query) }

    context 'when a station matches' do
      let(:query) { 'Leed' }

      it 'returns a hash containing one entry' do
        expect(result).to be_a Hash
        expect(result.length).to eq(1)
      end

      it 'returns the details of Leeds station in the hash' do
        expect(result['LDS'][:name]).to eq('Leeds')
        expect(result['LDS'][:longitude]).to eq(-1.5473)
        expect(result['LDS'][:latitude]).to eq(53.7947)
      end
    end

    context 'when two stations match' do
      let(:query) { 'Farnboro' }

      it 'returns a hash with two entries' do
        expect(result).to be_a Hash
        expect(result.length).to eq(2)
      end

      it 'returns the details of Farnborough Main' do
        expect(result['FNB'][:name]).to eq('Farnborough (Main)')
        expect(result['FNB'][:longitude]).to eq(-0.7554)
        expect(result['FNB'][:latitude]).to eq(51.2966)
      end

      it 'returns the details of Farnborough North' do
        expect(result['FNN'][:name]).to eq('Farnborough North')
        expect(result['FNN'][:longitude]).to eq(-0.7428)
        expect(result['FNN'][:latitude]).to eq(51.3023)
      end
    end

    context 'when no stations match' do
      let(:query) { 'Lorem Ipsum' }

      it 'returns an empty hash' do
        expect(result).to be_a(Hash)
        expect(result).to be_empty
      end
    end
  end

  describe '#all' do
    let(:stations_hash) { YAML.load_file(test_stations_yaml) }

    it 'returns all stations in the yaml' do
      expect(station.all).to eq(stations_hash)
    end
  end
end
