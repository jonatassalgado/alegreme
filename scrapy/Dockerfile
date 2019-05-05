FROM python:3

ENV TZ "America/Sao_Paulo"

ENV SCRAPY_ROOT /var/www/scrapy
RUN mkdir -p $SCRAPY_ROOT
RUN mkdir -p /var/www/scrapy/data/scraped
RUN mkdir -p /var/www/scrapy/data/classified

WORKDIR $SCRAPY_ROOT

ADD . $SCRAPY_ROOT

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY ./classified scrapy_shared:/var/www/scrapy/data/classified
COPY . .

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 7654

CMD ["scrapy-do", "-n", "scrapy-do", "--config", "scrapydo.conf"]