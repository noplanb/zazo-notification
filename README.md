# Zazo Notification service

## Stack

* [Rails](http://rubyonrails.org) web-framework.
* [Rails API](https://github.com/rails-api/rails-api) gem.
* [Twilio](https://twilio.com) for verification with code.
* [Rollbar](https://rollbar.com) for errors.
* [Wercker](http://wercker.com) for CI.
* [Docker](https://docker.com) for containers.
* [AWS Elasticbeanstalk](http://aws.amazon.com/ru/elasticbeanstalk/) for deploy.

## Setup

1. Copy and update config with correct values:

        cp config/application.yml.example config/application.yml

2. Install npm packages for development:

        npm install --global dredd aglio

2. Then run server:

        bin/rails s

   or use [Pow](http://pow.cx)

        ln -s $PWD ~/.pow/zazo_notification
        open http://zazo_notification.dev

## Specs

    bin/rake spec

## Dredd

    bin/rake dredd

## Docker

To build docker image

    bin/rake docker:build

And run it:

    bin/rake docker:run

## API documentation

API Blueprint documentation stored in [apiary.apib](./apiary.apib).
The HTML formatted version generated to [public/index.html](./public/index.html).

To generate `public/index.html` run:

    bin/rake aglio:generate

or for *slate*

    bin/rake aglio:generate[slate]
