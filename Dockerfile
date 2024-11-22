FROM ruby:3.1.6

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs bash

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4002

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && rails server -p 4002 -b 0.0.0.0"]

