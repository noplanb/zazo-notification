namespace :docker do
  desc 'Build Docker image to NAME'
  task :build do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    `docker build --tag #{name} .`
  end

  desc 'Run Docker image NAME at PORT'
  task :run do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    port = ENV['PORT'] || 8000
    `docker run --it -p #{port}:8000 --name #{name} #{name}`
  end
end
