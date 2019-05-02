FROM python:3

ENV SCRAPY_ROOT /var/www/scrapy
RUN mkdir -p $SCRAPY_ROOT

WORKDIR $SCRAPY_ROOT

ADD . $SCRAPY_ROOT

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 7654

CMD ["scrapy-do", "-n", "scrapy-do"]