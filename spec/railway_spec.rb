# frozen_string_literal: true

describe Railway do
  subject(:railway) { Railway.new(ldbws: ldbws_cfg, station_yaml: test_stations_yaml) }

  let(:ldbws_cfg) { { token: 'abc-123' } }
  let(:test_stations_yaml) { fixtures_path + 'test_stations.yml' }

  describe '#arrivals' do
    subject(:arrivals) { railway.arrivals(crs) }

    let(:crs) { 'FNN' }
    let(:service) { arrivals.select { |s| s.origin == 'RDG' }.first }

    it 'returns an array of services arriving at the provided CRS' do
      expect(arrivals).to be_an(Array)
      expect(arrivals).to_not be_empty
      expect(arrivals.map(&:class).uniq).to eq([Railway::LDBWS::Structs::Service])
    end

    it 'accurately describes a service' do
      expect(service.destination).to eq('RDH')
      expect(service.destination_name).to eq('Redhill')
      expect(service.origin).to eq('RDG')
      expect(service.origin_name).to eq('Reading')
      expect(service.st).to eq('10:29')
      expect(service.et).to eq('On time')
      expect(service.operator).to eq('GW')
      expect(service.operator_name).to eq('Great Western Railway')
      expect(service.service_type).to eq('train')
      expect(service.platform).to eq('1')
    end

    it 'has no calling points' do
      expect(service.calling_points).to be_empty
    end
  end

  describe '#departures' do
    subject(:departures) { railway.departures(crs) }

    let(:crs) { 'LDS' }
    let(:service) { departures.select { |s| s.destination == 'ILK' }.first }
    let(:calling_point) { service.calling_points.first }

    it 'returns an array of services departing from the provided CRS' do
      expect(departures).to be_an(Array)
      expect(departures).to_not be_empty
      expect(departures.map(&:class).uniq).to eq([Railway::LDBWS::Structs::Service])
    end

    it 'accurately describes a service' do
      expect(service.destination).to eq('ILK')
      expect(service.destination_name).to eq('Ilkley')
      expect(service.origin).to eq('LDS')
      expect(service.origin_name).to eq('Leeds')
      expect(service.st).to eq('10:03')
      expect(service.et).to eq('On time')
      expect(service.operator).to eq('NT')
      expect(service.operator_name).to eq('Northern')
      expect(service.service_type).to eq('train')
      expect(service.platform).to eq('5B')
      expect(service.calling_points.size).to eq(5)
    end

    it 'accurately describes a calling point' do
      expect(calling_point.station).to eq('GSY')
      expect(calling_point.station_name).to eq('Guiseley')
      expect(calling_point.length).to eq(4)
      expect(calling_point.st).to eq('10:14')
      expect(calling_point.et).to eq('On time')
    end

    context 'when the API returns a Soap Fault' do
      let(:crs) { 'SOAP_FAULT' }

      it 'raises an exception' do
        expect { departures }.to raise_error(Railway::SoapFault)
      end
    end
  end

  describe '#next_train' do
    subject(:departures) { railway.next_train(source, destinations, opts) }

    context 'when multiple destinations are supplied' do
      let(:source) { 'FNB' }
      let(:destinations) { %w[WAT LDS] }
      let(:opts) { {} }
      let(:waterloo) { departures['WAT'] }
      let(:leeds) { departures['LDS'] }

      it 'returns details for both destinations' do
        expect(departures.keys).to eq(destinations)
      end

      it 'correctly handles XML nils' do
        expect(leeds).to be_empty
      end

      it 'returns a response for Waterloo' do
        expect(waterloo.size).to be 1
        expect(waterloo.first.st).to eq '13:45'
        expect(waterloo.first.origin_name).to eq 'Basingstoke'
        expect(waterloo.first.origin).to eq 'BSK'
        expect(waterloo.first.destination_name).to eq 'London Waterloo'
        expect(waterloo.first.destination).to eq 'WAT'
        expect(waterloo.first.et).to eq 'On time'
        expect(waterloo.first.operator).to eq 'SW'
        expect(waterloo.first.operator_name).to eq 'South Western Railway'
        expect(waterloo.first.service_type).to eq 'train'
        expect(waterloo.first.platform).to eq '1'
        expect(waterloo.first.calling_points.size).to be 6
      end
    end
  end
end
