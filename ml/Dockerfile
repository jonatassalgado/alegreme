FROM python:3.7.1


ENV ML_ROOT /var/www/ml
ENV API_ROOT /var/www/ml/api
RUN mkdir -p $ML_ROOT

WORKDIR $ML_ROOT

RUN pip install --upgrade pip
COPY ./requirements.txt ./requirements.txt
RUN pip3 install -r $ML_ROOT/requirements.txt
RUN python3 -m spacy download pt

ADD . $ML_ROOT

WORKDIR $API_ROOT

CMD python3 app.py
