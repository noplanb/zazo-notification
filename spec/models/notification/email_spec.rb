require 'rails_helper'

RSpec.describe Notification::Email, type: :model do
  let(:instance) { described_class.new(params) }

  let(:email_from) { 'support@zazoapp.com' }
  let(:email_to) { Faker::Internet.email }
  let(:email_subject) { 'Testing Zazo notifications' }
  let(:email_body) { Faker::Lorem.paragraph }
  let(:params) { { to: email_to, subject: email_subject, body: email_body } }

  describe 'after initialize' do
    context '#to' do
      subject { instance.to }
      it { is_expected.to eq(email_to) }
    end

    context '#subject' do
      subject { instance.subject }
      it { is_expected.to eq(email_subject) }
    end

    context '#body' do
      subject { instance.body }
      it { is_expected.to eq(email_body) }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:to) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:subject) }
  end

  describe '#notify' do
    context 'on success' do
      subject { instance }
      before { instance.notify }

      it { is_expected.to be_valid }

      context 'deliveries' do
        subject { ActionMailer::Base.deliveries }
        it { is_expected.to_not be_empty }
      end

      context 'last mail' do
        let(:mail) { ActionMailer::Base.deliveries.last }
        subject { mail }

        context 'subject' do
          subject { mail.subject }
          it { is_expected.to eq(email_subject) }
        end

        context 'to' do
          subject { mail.to }
          it { is_expected.to eq([email_to]) }
        end

        context 'body' do
          subject { mail.body.to_s }
          it { is_expected.to eq(email_body) }
        end
      end
    end

    context 'on error' do
      subject { instance }
      before { allow(instance).to receive(:do_notify).and_raise(Net::SMTPFatalError.new('554 Message rejected: Email address is not verified.
')) }

      context 'valid?' do
        before { instance.notify }
        subject { instance.valid? }
        it { is_expected.to be false }
      end

      context 'errors' do
        before { instance.notify }
        subject { instance.errors }
        it { is_expected.to_not be_empty }
      end

      specify do
        expect(instance).to receive(:handle_error)
        instance.notify
      end
    end
  end
end
