require 'rails_helper'

RSpec.describe Notification::Base, type: :model do
  let(:instance) { described_class.new(foo: 'bar') }
  let(:hash) { { name: 'base', required_params: [] } }

  describe '#params' do
    subject { instance.params }
    it { is_expected.to eq(foo: 'bar') }
  end

  describe '.notification_name' do
    subject { described_class.notification_name }
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
