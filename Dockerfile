FROM openjdk:8-jre-alpine

ENV NODE_VERSION 8.11.2

LABEL maintainer="Vincent Voyer <vincent@zeroload.net>"
LABEL description="Docker container for running https://github.com/vvo/selenium-standalone to start the Selenium \
server and has the latest stable Chrome and Firefox browsers. \
You can use this container by extending it for use in your own repository where you run E2E tests."


RUN sed -i -e 's/v3\.7/edge/g' /etc/apk/repositories
RUN apk add --update \
  nodejs \
  nodejs-npm \
  curl \
  sudo

RUN node --version
RUN npm --version

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node
RUN echo 'node ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

WORKDIR /home/node
COPY package.json .
RUN mkdir node_modules
RUN chown node:node -R .
RUN chmod 777 -R .

RUN ls -al .

USER node
RUN npm install
RUN ls -al ./node_modules/selenium-standalone/
RUN ls -al ./node_modules/selenium-standalone/.selenium


ENTRYPOINT ["npm", "run", "selenium"]