# frozen_string_literal: true

describe Railway::LDBWS::Client do
  subject(:client) { described_class.new(opts) }
  let(:opts) { { token: token } }
  let(:token) { 'abc-123' }

  describe '.new' do
    context 'when no token is supplied' do
      let(:opts) { {} }

      it 'raises an error' do
        expect { client }.to raise_error(Railway::LDBWSError, 'Please specify an access :token')
      end
    end
  end
end
