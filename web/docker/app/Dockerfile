FROM ubuntu:16.04

ENV RUBY_MAJOR="2.5" \
    RUBY_VERSION="2.5.3" \
    DB_PACKAGES="libsqlite3-dev" \
    RUBY_PACKAGES="ruby2.5.3 ruby2.5.3-dev"


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      curl \
      git-all \
      libffi-dev \
      libgdbm-dev \
      libncurses-dev \
      libreadline6-dev \
      libssl-dev \
      libyaml-dev \
      zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN echo 'gem: --no-document' >> /.gemrc

RUN mkdir -p /tmp/ruby \
  && curl -L "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
      | tar -xjC /tmp/ruby --strip-components=1 \
  && cd /tmp/ruby \
  && ./configure --disable-install-doc \
  && make \
  && make install \
  && gem update --system \
  && rm -r /tmp/ruby

RUN rm -fr /usr/local/bin/bundle
RUN gem install --no-document bundler


RUN apt-get update && curl --silent --location https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client postgresql-client libsqlite3-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn
RUN yarn install --check-files

ENV RAILS_VERSION 5.2.1

RUN gem install rails --version "$RAILS_VERSION"



ENV RAILS_ROOT /var/www/alegreme
RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

#ENV RAILS_ENV='production'
#ENV RACK_ENV='production'

COPY ./docker/app/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 20 --retry 5

COPY . .
RUN bundle exec rake assets:precompile
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
