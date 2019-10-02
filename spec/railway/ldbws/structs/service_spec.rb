# frozen_string_literal: true

describe Railway::LDBWS::Structs::Service do
  subject(:service) { described_class.new(opts) }
  let(:opts) do
    {
      origin_name: 'Leeds',
      origin: 'LDS',
      destination_name: 'Ilkley',
      destination: 'ILK',
      st: '10:03',
      et: 'On time',
      operator: 'NT',
      operator_name: 'Northern',
      service_type: 'train',
      platform: '5B',
      calling_points: [
        { station: 'GSY', station_name: 'Guiseley', st: '10:14', et: 'On time', length: 4 },
        { station: 'MNN', station_name: 'Menston', st: '10:18', et: 'On time', length: 4 },
        { station: 'BUW', station_name: 'Burley-in-Wharfedale', st: '10:20', et: 'On time', length: 4 },
        { station: 'BEY', station_name: 'Ben Rhydding', st: '10:24', et: 'On time', length: 4 },
        { station: 'ILK', station_name: 'Ilkley', st: '10:31', et: 'On time', length: 4 }
      ]
    }
  end

  describe '#to_h' do
    it 'serializes the object into a hash' do
      expect(service.to_h).to eq(opts)
    end

    it 'can be deserialized back into the object' do
      expect(described_class.new(service.to_h)).to eq(service)
    end
  end
end
