require 'rails_helper'

RSpec.describe Metric::Base, type: :model do
  let(:instance) { described_class.new(foo: 'bar') }
  let(:hash) { { name: 'base', type: :aggregated } }

  describe '#attributes' do
    subject { instance.attributes }
    it { is_expected.to eq('foo' => 'bar') }
  end

  describe '.metric_name' do
    subject { described_class.metric_name }
    it { is_expected.to eq('base') }
  end

  describe '.to_hash' do
    subject { described_class.to_hash }
    it { is_expected.to eq(hash) }
  end

  describe '.to_json' do
    subject { described_class.to_json }
    it { is_expected.to eq(hash.to_json) }
  end
end
