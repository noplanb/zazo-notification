# Zazo Notification service

## Stack

* [Rails](http://rubyonrails.org) web-framework.
* [Rails API](https://github.com/rails-api/rails-api) gem.
* [MySQL](http://mysql.org) for data storage.
* [Twilio](https://twilio.com) for verification with code.
* [Rollbar](https://rollbar.com) for errors.
* [Wercker](http://wercker.com) for CI.
* [Docker](https://docker.com) for containers.
* [AWS Elasticbeanstalk](http://aws.amazon.com/ru/elasticbeanstalk/) for deploy.

## Setup

1. Copy and update config with correct values:

        cp config/application.yml.example config/application.yml

2. Prepare database:

        bin/rake db:migrate

3. Then run server:

        bin/rails s

   or use [Pow](http://pow.cx)

        ln -s $PWD ~/.pow/zazo_notification
        open http://zazo_notification.dev

## Specs

    bin/rake spec
