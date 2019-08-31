FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

ENV SIDEKIQ_ROOT /var/www/sidekiq
RUN mkdir -p $SIDEKIQ_ROOT


WORKDIR $SIDEKIQ_ROOT


ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"


RUN mkdir -p config
COPY ./docker/sidekiq/config.yml config.yml
COPY Gemfile Gemfile


RUN bundle install --jobs 20 --retry 5
RUN bundle update --bundler


COPY ./docker/sidekiq/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]


CMD bundle exec sidekiq -C config.yml
