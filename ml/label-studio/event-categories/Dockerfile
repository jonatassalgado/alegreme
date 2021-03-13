FROM heartexlabs/label-studio:latest


ENV ROOT /label-studio
RUN mkdir -p $ROOT

WORKDIR $ROOT

COPY ./tools/run.sh ./tools
RUN chmod +x ./tools/run.sh

COPY ./docker-entrypoint.sh ./
RUN ["chmod", "+x", "./docker-entrypoint.sh"]
ENTRYPOINT ["sh", "./docker-entrypoint.sh"]

RUN pip install --upgrade pip
COPY ./requirements.txt ./
RUN pip install -r $ROOT/requirements.txt

ENV PORT="8080"
ENV PROJECT_NAME="project"
ENV HOST=0.0.0.0
ENV PROTOCOL=http://
# basic auth params
ENV USERNAME=""
ENV PASSWORD=""

EXPOSE ${PORT}

ADD . /label-studio

CMD ["bash", "./tools/run.sh"]
