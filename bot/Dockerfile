FROM node:slim

ENV TZ 'America/Sao_Paulo'

ENV BOT_ROOT /var/www/bot
RUN mkdir -p $BOT_ROOT

WORKDIR $BOT_ROOT
ADD . $BOT_ROOT

WORKDIR $BOT_ROOT/eme
RUN npm install --production

CMD npm start
