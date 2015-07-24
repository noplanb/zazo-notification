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
    port = ENV['PORT'] || 80
    system "docker run --rm=true --publish=#{port}:80 --name #{name} #{name}"
  end

  desc 'Start Docker container'
  task :start do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    conatiner_id = `docker ps -a | grep #{name} | head -n 1 | awk '{print $1}'`
    if conatiner_id.present?
      system "docker start #{conatiner_id}"
    else
      $stderr.puts "#{name} not exists"
    end
  end

  desc 'Stop Docker container'
  task :stop do
    name = ENV['NAME'] || ENV['app_name'] || 'zazo-notification'
    conatiner_id = `docker ps | grep #{name} | head -n 1 | awk '{print $1}'`
    if conatiner_id.present?
      system "docker stop #{conatiner_id}"
    else
      $stderr.puts "#{name} not runned"
    end
  end
end
