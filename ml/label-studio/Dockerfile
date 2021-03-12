FROM heartexlabs/label-studio:latest


ENV ROOT /label-studio
RUN mkdir -p $ROOT

WORKDIR $ROOT

# COPY ./docker-entrypoint.sh ./
# RUN chmod +x ./docker-entrypoint.sh
# ENTRYPOINT ["./docker-entrypoint.sh"]

RUN pip install --upgrade pip
COPY ./requirements.txt ./
RUN pip install -r $ROOT/requirements.txt

CMD label-studio start events