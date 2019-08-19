FROM ruby:2.6.3


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

# ENV RUBY_MAJOR="2.6" \
#     RUBY_VERSION="2.6.1" \
#     DB_PACKAGES="libsqlite3-dev" \
#     RUBY_PACKAGES="ruby2.6.1 ruby2.6.1-dev"


RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      nano \
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
      libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# RUN echo 'gem: --no-document' >> /.gemrc

# RUN mkdir -p /tmp/ruby \
#   && curl -L "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
#       | tar -xjC /tmp/ruby --strip-components=1 \
#   && cd /tmp/ruby \
#   && ./configure --disable-install-doc \
#   && make \
#   && make install \
#   && gem update --system \
#   && rm -r /tmp/ruby

RUN rm -fr /usr/local/bin/bundle
RUN gem install --no-document bundler


RUN apt-get update && curl --silent --location https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
# RUN apt-get update && apt-get install -y libsqlite3-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*


RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn


# INSTALL POSTGRES 11
RUN apt-get install -y wget \
                       ca-certificates
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y postgresql-client-10


# ENV RAILS_VERSION 5.2.1
# RUN gem install rails --version "$RAILS_VERSION"


ENV RAILS_ROOT /var/www/alegreme
RUN mkdir -p $RAILS_ROOT


WORKDIR $RAILS_ROOT


COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]


ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"


COPY Gemfile Gemfile


RUN bundle install --jobs 20 --retry 5
RUN bundle update --bundler


COPY . .


RUN rake webpacker:clobber
RUN rake assets:precompile
RUN yarn install

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb
