FROM python:3.7.1


ENV ML_ROOT /var/www/ml
ENV API_ROOT /var/www/ml/api
RUN mkdir -p $ML_ROOT

WORKDIR $ML_ROOT

ADD . $ML_ROOT
RUN pip install -r $ML_ROOT/requirements.txt

WORKDIR $API_ROOT

CMD python app.py
