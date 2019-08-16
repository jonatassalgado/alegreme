FROM python:3

ENV TZ "America/Sao_Paulo"

ENV SCRAPY_ROOT /var/www/scrapy
RUN mkdir -p $SCRAPY_ROOT

WORKDIR $SCRAPY_ROOT
COPY . $SCRAPY_ROOT


COPY requirements.txt ./
RUN pip install -r requirements.txt


# RUN mkdir -p data/scraped
# RUN mkdir -p data/classified

# COPY ./classified ./data/classified
# COPY ./scraped ./data/scraped

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

#COPY . .

EXPOSE 7654

CMD ["scrapy-do", "-n", "scrapy-do", "--config", "scrapydo.conf"]
