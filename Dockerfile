FROM ruby:3.1.6

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4000

CMD ["sh", "-c", "rm -f tmp/pids/server.pid && rails server -b 0.0.0.0"]
