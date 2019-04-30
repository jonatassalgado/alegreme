FROM elasticsearch:7.0.0

ENV SEARCH_ROOT /var/www/elasticsearch
RUN mkdir -p $SEARCH_ROOT

WORKDIR $SEARCH_ROOT

ADD . $SEARCH_ROOT

