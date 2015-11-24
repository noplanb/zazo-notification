require 'rails_helper'

RSpec.describe Notification::Mobile, type: :model do
  let(:instance) { described_class.new params }

  let(:mobile_subject) { 'Testing Zazo notifications' }
  let(:mobile_content) { Faker::Lorem.paragraph }
  let(:mobile_device_token) { SecureRandom.hex }
  let(:mobile_device_build) { described_class::ALLOWED_DEVICE_BUILDS.sample }
  let(:mobile_device_platform) { described_class::ALLOWED_DEVICE_PLATFORMS.sample }
  let(:mobile_payload) do
    { type: 'friend_joined',
      content: mobile_content }
  end

  let(:params) do
    { subject: mobile_subject,
      device_build: mobile_device_build,
      device_token: mobile_device_token,
      device_platform: mobile_device_platform,
      payload: mobile_payload }
  end

  describe 'after initialize' do
    context '#subject' do
      it { expect(instance.subject).to eq(mobile_subject) }
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
    it { is_expected.to validate_presence_of(:device_build) }
    it { is_expected.to validate_presence_of(:device_token) }
    it { is_expected.to validate_presence_of(:device_platform) }
    it { is_expected.to validate_presence_of(:payload) }

    describe 'payload structure validation' do
      before { instance.valid? }

      context 'correct payload' do
        it { expect(instance).to be_valid }
      end

      context 'payload without type' do
        let(:mobile_payload) { { content: mobile_content } }

        it { expect(instance).to be_invalid }
        it { expect(instance.errors.messages[:payload]).to eq ['type attribute should be persisted'] }
      end

      context 'payload is not a hash' do
        let(:mobile_payload) { mobile_content }

        it { expect(instance).to be_invalid }
        it { expect(instance.errors.messages[:payload]).to eq ['should be type of hash'] }
      end
    end
  end

  describe '#notify' do

    #
    # android platform
    #

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

    #
    # ios platform
    #

    context 'ios platform' do
      let(:mobile_device_platform) { 'ios' }
      let(:ios_notification) do
        notification_params = instance.send :notification_params
        n = Houston::Notification.new(notification_params.slice(:token, :alert, :badge, :content_available))
        n.custom_data = notification_params[:payload]
        n.sound = 'NotificationTone.wav'
        n
      end

      before do
        allow_any_instance_of(GenericPushNotification).to receive(:ios_notification).and_return(ios_notification)
      end

      context 'success' do
        before do
          allow(ios_notification).to receive(:sent?).and_return true
          instance.notify
        end

        it { expect(instance).to be_valid }
        it do
          expected = { status: :success, unregistered_devices: [] }
          expect(instance.original_response).to eq expected
        end
      end

      context 'error' do
        before do
          allow(ios_notification).to receive(:error).and_return Houston::Notification::APNSError.new(2)
          allow(ios_notification).to receive(:sent?).and_return false
          instance.notify
        end

        it { expect(instance).to be_invalid }
        it { expect(instance.errors.to_json).to eq '{"response":["#\\u003cHouston::Notification::APNSError: Missing device token\\u003e"]}' }
        it do
          expected = { error: '#<Houston::Notification::APNSError: Missing device token>', status: :failure, unregistered_devices: [] }
          expect(instance.original_response).to eq expected
        end
      end
    end
  end
end
