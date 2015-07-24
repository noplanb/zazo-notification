require 'rails_helper'

RSpec.describe VerificationCodeSender do
  MESSAGE_PREFIX = "#{Settings.app_name} access code:"
  let(:mobile_number) { Figaro.env.twilio_to_number }
  let(:user) { create(:user, mobile_number: mobile_number) }
  let(:instance) { described_class.new(user) }

  describe '#send_code' do
    subject { instance.send_code }

    Settings.verification_code_sms_countries.each do |cc_iso|
      context cc_iso do
        let(:mobile_number) { sample_number(cc_iso.to_sym) }
        it 'sends sms' do
          expect(instance).to receive(:send_verification_sms).and_return(:ok)
          subject
        end
      end
    end

    context 'in' do
      let(:mobile_number) { sample_number(:in) }
      it 'makes call' do
        expect(instance).to receive(:make_verification_call).and_return(:ok)
        subject
      end
    end
  end

  describe '#from' do
    subject { instance.from }
    it { is_expected.to eq(Figaro.env.twilio_from_number) }
  end

  describe '#to' do
    subject { instance.to }
    it { is_expected.to eq(mobile_number) }
  end

  describe '#message' do
    let(:user) { build(:user) }
    it "starts with '#{MESSAGE_PREFIX}'" do
      expect(instance.message.match /^#{MESSAGE_PREFIX}/)
    end

    it 'ends with access code' do
      code = instance.message.match(/\d+$/).to_s
      expect(code.length).to eq Settings.verification_code_length
    end
  end

  describe '#twilio_call_url' do
    subject { instance.twilio_call_url }
    it { is_expected.to eq('http://zazo.test/verification_code/say_code') }
  end

  describe '#twilio_call_fallback_url' do
    subject { instance.twilio_call_fallback_url }
    it { is_expected.to eq('http://zazo.test/verification_code/call_fallback') }
  end

  describe '#send_verification_sms' do
    subject { instance.send_verification_sms }

    context 'on success' do
      around do |example|
        VCR.use_cassette('twilio_message_with_success', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number }) do
          example.run
        end
      end

      it { is_expected.to eq(:ok) }

      context 'user status' do
        specify do
          expect { subject }.to change { instance.user.reload.status }
            .from('initialized').to('registered')
        end
      end
    end

    context 'on invalid number' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 21_614, message: "'To' number is not a valid mobile number" } }

      around do |example|
        VCR.use_cassette('twilio_message_with_error', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number }.merge(error)) do
            example.run
        end
      end

      it { is_expected.to eq(:invalid_mobile_number) }

      context 'user status' do
        specify do
          expect { subject }.to change { instance.user.reload.status }
            .from('initialized').to('failed_to_register')
        end
      end
    end

    context 'other error' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 14_101, message: "'To' Attribute is Invalid" } }
      around do |example|
        VCR.use_cassette('twilio_message_with_error', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number }.merge(error)) do
            example.run
        end
      end

      it { is_expected.to eq(:other) }

      context 'user status' do
        specify do
          expect { subject }.to change { instance.user.reload.status }
            .from('initialized').to('failed_to_register')
        end

        context 'for verified user' do
          let(:user) { create(:user, mobile_number: mobile_number, status: 'verified') }
          specify do
            expect { subject }.to change { instance.user.reload.status }
              .from('verified').to('failed_to_register')
          end
        end
      end
    end
  end

  describe '#make_verification_call' do
    subject { instance.make_verification_call }
    let(:mobile_number) { Figaro.env.twilio_to_number }

    context 'on success' do
      around do |example|
        VCR.use_cassette('twilio_call_with_success', erb: {
                           twilio_ssid: Figaro.env.twilio_ssid,
                           twilio_token: Figaro.env.twilio_token,
                           from: Figaro.env.twilio_from_number,
                           to: mobile_number,
                           url: instance.twilio_call_url,
                           fallback_url: instance.twilio_call_fallback_url
                         }) do
          example.run
        end
      end

      context 'user status' do
        specify do
          expect { subject }.to change { instance.user.reload.status }
            .from('initialized').to('registered')
        end
      end

      it { is_expected.to eq(:ok) }
    end

    context 'on invalid number' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 21_614, message: "'To' number is not a valid mobile number" } }

      around do |example|
        VCR.use_cassette('twilio_call_with_error', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number,
          url: instance.twilio_call_url,
          fallback_url: instance.twilio_call_fallback_url
        }.merge(error)) do
          example.run
        end
      end

      it { is_expected.to eq(:invalid_mobile_number) }

      context 'user status' do
        specify do
          expect { subject }.to change { instance.user.reload.status }
            .from('initialized').to('failed_to_register')
        end

        context 'for verified user' do
          let(:user) { create(:user, mobile_number: mobile_number, status: 'verified') }
          specify do
            expect { subject }.to change { instance.user.reload.status }
              .from('verified').to('failed_to_register')
          end
        end
      end
    end

    context 'other error' do
      let(:mobile_number) { '+20227368296' }
      let(:error) { { code: 14_101, message: "'To' Attribute is Invalid" } }

      around do |example|
        VCR.use_cassette('twilio_call_with_error', erb: {
          twilio_ssid: Figaro.env.twilio_ssid,
          twilio_token: Figaro.env.twilio_token,
          from: Figaro.env.twilio_from_number,
          to: mobile_number,
          url: instance.twilio_call_url,
          fallback_url: instance.twilio_call_fallback_url
        }.merge(error)) do
          example.run
        end
      end

      it { is_expected.to eq(:other) }

      context 'user status' do
        specify do
          expect { subject }.to change { instance.user.reload.status }
            .from('initialized').to('failed_to_register')
        end
        context 'for verified user' do
          let(:user) { create(:user, mobile_number: mobile_number, status: 'verified') }
          specify do
            expect { subject }.to change { instance.user.reload.status }
              .from('verified').to('failed_to_register')
          end
        end
      end
    end
  end
end
