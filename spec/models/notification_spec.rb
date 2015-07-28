require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe '.find' do
    subject { described_class.find(notification_name) }

    context 'unknown' do
      let(:notification_name) { :unknown }
      specify do
        expect { subject }.to raise_error('Notification :unknown not found')
      end
    end

    context 'sms' do
      let(:notification_name) { :sms }
      it { is_expected.to eq(Notification::Sms) }
    end
  end

  describe '.all' do
    subject { described_class.all }
    let(:all_notifications) do
      [
        Notification::Email,
        Notification::Sms
      ]
    end
    it { is_expected.to eq(all_notifications) }
  end
end
