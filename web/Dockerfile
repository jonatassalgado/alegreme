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


# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && curl --silent --location https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql-client libsqlite3-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_VERSION 5.2.1

RUN gem install rails --version "$RAILS_VERSION"

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install


RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn
RUN yarn install --check-files

ENV app /app
RUN mkdir $app
WORKDIR $app
ADD . $app
