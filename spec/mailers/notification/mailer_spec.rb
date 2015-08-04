require 'rails_helper'

RSpec.describe Notification::Mailer, type: :mailer do
  describe 'notification' do
    let(:email_to) { Faker::Internet.email }
    let(:email_subject) { 'Testing Zazo notifications' }
    let(:email_body) { "<h1>Test</h1><p>#{Faker::Lorem.paragraph}</p>" }
    let(:email_from) { 'support@zazoapp.com' }
    let(:email_content_type) { 'text/html; charset=UTF-8' }
    let(:params) do
      { to: email_to,
        from: email_from,
        subject: email_subject,
        body: email_body,
        content_type: email_content_type }
    end
    let(:mail) { Notification::Mailer.notification(params) }

    context 'body' do
      subject { mail.body }
      it { is_expected.to include(email_body) }
    end

    context 'to' do
      subject { mail.to }
      it { is_expected.to eq([email_to]) }
    end

    context 'from' do
      subject { mail.from }
      it { is_expected.to eq([email_from]) }
    end

    context 'subject' do
      subject { mail.subject }
      it { is_expected.to eq(email_subject) }
    end

    context 'content_type' do
      subject { mail.content_type }
      it { is_expected.to eq(email_content_type) }
    end
  end
end
