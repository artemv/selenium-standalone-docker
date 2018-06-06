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

RUN useradd -d /home/testuser -m testuser
RUN mkdir -p /home/testuser
RUN chown testuser:testuser /home/testuser
WORKDIR /home/testuser
USER testuser

RUN npm install -i selenium-standalone
RUN ./node_modules/.bin/selenium-standalone install

EXPOSE 4444

RUN google-chrome --version
RUN firefox --version
RUN node --version
RUN npm --version

ENTRYPOINT ["./node_modules/.bin/selenium-standalone", "start"]