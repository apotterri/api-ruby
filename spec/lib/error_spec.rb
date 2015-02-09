require 'spec_helper'

describe Conjur::Error do
  let(:body) do
    '{"error": { "kind": "RecordNotFound", "message": ' \
        '"a descriptive error message", "details": "details of the error" }}'
  end
  subject(:error) { Conjur::Error.create body }

  describe '.create' do
    it 'returns nil if the source is not in valid format' do
      expect(Conjur::Error.create "something inappropriate").to be_nil
    end

    it 'chooses appropriate subclass based on the error kind' do
      expect(subject.class.name.to_s).to eq 'Conjur::Error::RecordNotFound'
    end
  end

  describe '#message' do
    it 'corresponds to error message in the response' do
      expect(error.message).to eq "a descriptive error message"
    end
  end

  describe '#kind' do
    it 'corresponds to error kind in the response' do
      expect(error.kind).to eq "RecordNotFound"
    end
  end

  describe '#details' do
    it 'corresponds to the response field' do
      expect(error.details).to eq 'details of the error'
    end
  end
end
