FROM python:3.7.1

ENV app /app
ENV api $app/api

RUN mkdir $app

ADD . $app
RUN pip install -r $app/requirements.txt


WORKDIR $api
CMD python app.py
