namespace :docker do
  desc 'Build Docker image to NAME'
  task :build do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    system "docker build --rm=true --tag #{name} #{Rails.root}"
  end

  desc 'Remove Docker container NAME'
  task :rm do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    system "docker rm #{name}"
  end

  desc 'Run Docker image NAME at PORT'
  task :run do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    port = ENV['PORT'] || 8000
    system "docker run --rm=true --interactive=false --tty=false --publish=#{port}:8000 --name #{name} #{name}"
  end
end
