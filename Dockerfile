FROM ubuntu:latest

LABEL maintainer="Vincent Voyer <vincent@zeroload.net>"
LABEL description="Docker container for running https://github.com/vvo/selenium-standalone to start the Selenium \
server and has the latest stable Chrome and Firefox browsers. \
You can use this container by extending it for use in your own repository where you run E2E tests."

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get -qqy update
RUN apt-get -qqy install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main universe\n" >> /etc/apt/sources.list
RUN apt-get -qqy update


RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -qqy --no-install-recommends install \
  nodejs \
  firefox \
  google-chrome-stable \
  openjdk-8-jre-headless \
  x11vnc \
  xvfb \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-scalable \
  xfonts-cyrillic

RUN export DISPLAY=:99.0
RUN Xvfb :99 -shmem -screen 0 1366x768x16 &

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

WORKDIR /home/node
COPY package.json .
RUN chown -R node .
ENV NPM_CONFIG_PREFIX=~/.npm-global

USER node

RUN npm install -g npm
RUN npm install --production --loglevel=warn
RUN ls -al ./node_modules/selenium-standalone/.selenium
RUN ls -al ./node_modules/selenium-standalone/.selenium/chromedriver


EXPOSE 4444


RUN google-chrome --version
RUN firefox --version
RUN node --version
RUN npm --version
RUN java -version

ENTRYPOINT npm run selenium