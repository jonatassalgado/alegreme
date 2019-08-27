FROM nginx

RUN apt-get update -qq && apt-get -y install apache2-utils

ENV RAILS_ROOT /var/www/alegreme

WORKDIR $RAILS_ROOT

RUN mkdir -p log
RUN mkdir -p cache/nginx-rails

# COPY public public/

COPY docker/web/nginx.conf /tmp/docker.nginx

RUN mkdir -p .well-known
COPY docker/web/.well-known .well-known/

RUN envsubst '$RAILS_ROOT' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf
EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
