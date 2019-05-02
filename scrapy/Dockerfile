FROM python:3

ENV SCRAPY_ROOT /var/www/scrapy
RUN mkdir -p $SCRAPY_ROOT

WORKDIR $SCRAPY_ROOT

ADD . $SCRAPY_ROOT

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# CMD ["scrapy", "runspider", "crawler/myspider.py"]