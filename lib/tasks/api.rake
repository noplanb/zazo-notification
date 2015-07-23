namespace :api do
  desc '/api/v1/notifications/sms'
  task sms: :environment do
    values = '{
      "mobile_number": "+380939523746",
      "body": "Hello from Zazo!"
    }'

    headers = {
      content_type: 'application/json'
    }

    api_host = ENV['API_HOST'] || 'private-b91a9-zazonotification.apiary-mock.com'
    response = Faraday.post "http://#{api_host}/api/v1/notifications/sms", values, headers
    puts response.body
  end
end
