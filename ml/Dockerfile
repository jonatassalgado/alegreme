FROM python:3.7.1


ENV ML_ROOT /var/www/ml
ENV API_ROOT /var/www/ml/api
RUN mkdir -p $ML_ROOT

WORKDIR $ML_ROOT

COPY ./requirements.txt ./requirements.txt
RUN pip install -r $ML_ROOT/requirements.txt
RUN python -m spacy download pt

ADD . $ML_ROOT

WORKDIR $API_ROOT

CMD python app.py
