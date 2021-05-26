FROM python:3.7

WORKDIR /tmp
COPY requirements.txt .

RUN pip install --no-cache \
    -r requirements.txt \
    uwsgi==2.0.19.1 \
    supervisor==4.2.2 \
    label-studio==1.0.2 \
    git+https://github.com/heartexlabs/label-studio-ml-backend

WORKDIR /ls

EXPOSE 8080
