require 'rails_helper'

RSpec.describe Notification::Mobile, type: :model do
  let(:instance) { described_class.new params }

  let(:mobile_subject) { 'Testing Zazo notifications' }
  let(:mobile_content) { Faker::Lorem.paragraph }
  let(:mobile_device_token) { SecureRandom.hex }
  let(:mobile_device_build) { described_class::ALLOWED_DEVICE_BUILDS.sample }
  let(:mobile_device_platform) { described_class::ALLOWED_DEVICE_PLATFORMS.sample }

  let(:params) do
    { subject: mobile_subject,
      content: mobile_content,
      device_build: mobile_device_build,
      device_token: mobile_device_token,
      device_platform: mobile_device_platform }
  end

  describe 'after initialize' do
    context '#subject' do
      it { expect(instance.subject).to eq(mobile_subject) }
    end

    context '#content' do
      it { expect(instance.content).to eq(mobile_content) }
    end

    context '#device_build' do
      it { expect(instance.device_build).to eq(mobile_device_build) }
    end

    context '#device_token' do
      it { expect(instance.device_token).to eq(mobile_device_token) }
    end

    context '#device_platform' do
      it { expect(instance.device_platform).to eq(mobile_device_platform) }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:device_build) }
    it { is_expected.to validate_presence_of(:device_token) }
    it { is_expected.to validate_presence_of(:device_platform) }
  end

  describe '#notify' do
    context 'android platform' do
      let(:mobile_device_platform) { 'android' }

      context 'success' do
        before do
          VCR.use_cassette('gcm_send_with_success', erb: { key: 'gcmkey', payload: instance.payload }) { instance.notify }
        end
        it { expect(instance).to be_valid }
      end

      context 'error' do
        before do
          VCR.use_cassette('gcm_send_with_error', erb: { key: 'gcmkey', payload: instance.payload }) { instance.notify }
        end
        it { expect(instance).to be_invalid }
        it { expect(instance.errors.to_json).to eq '{"response":["InvalidRegistration"]}' }
      end

      context 'server error' do
        before do
          VCR.use_cassette('gcm_send_with_server_error', erb: { key: 'gcmkey', payload: instance.payload }) { instance.notify }
        end
        it { expect(instance).to be_invalid }
        it { expect(instance.errors.to_json).to eq '{"response":["body in not exist, possible server error"]}' }
      end
    end
  end
end
