FROM elasticsearch:7.9.2

ENV SEARCH_ROOT /var/www/elasticsearch
RUN mkdir -p $SEARCH_ROOT

WORKDIR $SEARCH_ROOT

ADD . $SEARCH_ROOT
