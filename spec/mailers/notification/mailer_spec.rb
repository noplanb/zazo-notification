require 'rails_helper'

RSpec.describe Notification::Mailer, type: :mailer do
  describe 'notification' do
    let(:email_recipient) { Faker::Internet.email }
    let(:email_subject) { 'Testing Zazo notifications' }
    let(:email_body) { Faker::Lorem.paragraph }
    let(:email_from) { 'support@zazoapp.com' }
    let(:params) do
      { recipient: email_recipient,
        subject: email_subject,
        body: email_body }
    end

    let(:mail) { Notification::Mailer.notification(params) }

    it 'renders the headers' do
      expect(mail.subject).to eq(email_subject)
      expect(mail.to).to eq([email_recipient])
      # expect(mail.from).to eq([email_from])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(email_body)
    end
  end
end
