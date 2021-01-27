FROM ruby:2.7.2

RUN apt-get update && apt-get install -y locales locales-all
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ "America/Sao_Paulo"
RUN echo $TZ > /etc/timezone && \
  apt-get update && apt-get install -y tzdata && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get clean


RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN apt-get update && curl --silent --location https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

ENV SIDEKIQ_ROOT /var/www/sidekiq
ENV RAILS_ROOT /var/www/alegreme
RUN mkdir -p $SIDEKIQ_ROOT
WORKDIR $SIDEKIQ_ROOT

RUN mkdir -p config
COPY ./docker/sidekiq/config.yml config.yml

RUN gem install bundler
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install

COPY ./docker/sidekiq/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]


COPY . $SIDEKIQ_ROOT

#RUN yarn install
#
#RUN bundle exec rake assets:clobber
#RUN bundle exec rake webpacker:clobber
#RUN bundle exec rake assets:precompile
#RUN bundle exec rake webpacker:compile

CMD bundle exec sidekiq -C config.yml
