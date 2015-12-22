require 'rails_helper'

RSpec.describe GenericPushNotification do
  let(:sample_ios_token) { '0d13491051bfe2f9395f92ca00b9ec6db28429d6b2bfd20680432c7ca7cf7979' }
  let(:sample_android_token) { 'APA91bHzjK1yDDt91cK3sVHbHq267Sv4ny2frCjdyd5eeYQkLGgVEW0UWSWiYpBvmuf-l3nOIGfCqnNhtOtHJGeVQYxCxiXrqtk2PUeMwrKPFzeJdCgYs4Q2kEx2HK-k6pN_wcThu-iPnIAEgyMeDZ1XDmp0G6zupQ' }

  let(:original_target_data) do
    { device_platform: [:ios, :android].sample,
      device_build: :dev,
      push_token: Faker::Lorem.characters(20) }
  end
  let(:modified_target_data) { {} }
  let(:target_data) { original_target_data.merge(modified_target_data) }
  let(:attributes) do
    { platform: target_data[:device_platform],
      build: target_data[:device_build],
      token: target_data[:push_token],
      type: :alert,
      payload: { type: 'video_received',
                 from_mkey: Faker::Lorem.characters(20),
                 video_id: (Time.now.to_f * 1000).to_i.to_s,
                 host: 'zazo.test' },
      alert: 'Friend joined!',
      badge: 10,
      content_available: true }
  end

  let(:instance) { described_class.new(attributes) }
  let(:ios_notification) do
    n = Houston::Notification.new(attributes.slice(:token,
                                                   :alert,
                                                   :badge,
                                                   :content_available))
    n.custom_data = attributes[:payload]
    n.sound = 'NotificationTone.wav'
    n
  end

  describe '.send_notification' do
    subject { described_class.send_notification(attributes) }

    specify do
      expect_any_instance_of(described_class).to receive(:send_notification)
      subject
    end
  end

  describe '#send_notification' do
    subject { instance.send_notification }

    context 'Android' do
      let(:modified_target_data) { { device_platform: :android, push_token: sample_android_token } }
      let(:payload) do
        GcmServer.make_payload(attributes[:token], attributes[:payload])
      end

      specify do
        expect(GcmServer).to receive(:send_notification).with(attributes[:token],
                                                              attributes[:payload])
        VCR.use_cassette('gcm_send_with_error',
                         erb: { key: Figaro.env.gcm_api_key, payload: payload }) do
          subject
        end
      end
    end

    context 'iOS' do
      let(:modified_target_data) { { device_platform: :ios, push_token: sample_ios_token } }

      specify 'expects any instance of Houston::Client receives :push' do
        allow(instance).to receive(:ios_notification).and_return(ios_notification)
        expect_any_instance_of(Houston::Client).to receive(:push).with(ios_notification)
        subject
      end

      it { is_expected.to be_truthy }

      context 'with empty token' do
        let(:modified_target_data) { { device_platform: :ios, push_token: '' } }
        before do
          allow(instance.ios_notification).to receive(:error).and_return Houston::Notification::APNSError.new(2)
        end

        it 'notifies Rollbar with error' do
          allow(instance.ios_notification).to receive(:sent?).and_return false
          expect(Rollbar).to receive(:error).with(instance.ios_notification.error, notification: instance.ios_notification)
          subject
        end
        it { is_expected.to be_truthy }
      end

      context 'when unregistered_devices not empty' do
        let(:unregistered_devices) { [{ token: 'push token', timestamp: 12345678 }] }
        before { allow(instance).to receive(:unregistered_devices).and_return(unregistered_devices) }
        specify do
          expect(Rollbar).to receive(:info).with('APNS returned non-empty unregistered devices',
                                                 unregistered_devices: unregistered_devices)
          subject
        end
      end
    end
  end

  describe '#ios_notification' do
    subject { instance.ios_notification }
    it { is_expected.to be_valid }
    context 'custom_data' do
      subject { instance.ios_notification.custom_data }
      it { is_expected.to eq(attributes[:payload]) }
    end
  end

  describe '#apns' do
    subject { instance.apns }

    context 'gateway_uri' do
      subject { instance.apns.gateway_uri }

      context 'for dev build' do
        let(:modified_target_data) { { device_platform: :ios, device_build: :dev } }
        it { is_expected.to eq(Houston::APPLE_DEVELOPMENT_GATEWAY_URI) }
      end

      context 'for prod build' do
        let(:modified_target_data) { { device_platform: :ios, device_build: :prod } }
        it { is_expected.to eq(Houston::APPLE_PRODUCTION_GATEWAY_URI) }
      end
    end
  end

  describe '#unregistered_devices' do
    context 'iOS' do
      let(:modified_target_data) { { device_platform: :ios } }
      before { instance.send_notification }
      it { expect(instance.unregistered_devices).to eq [] }
    end
  end
end
