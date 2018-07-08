FROM ubuntu:16.04

WORKDIR /opt/app

ENV NODE_VERSION=v8.11.1

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev libprotobuf-dev pkg-config wget && \
    cd /tmp && \
    wget --quiet https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.gz && \
    tar -xzf node-$NODE_VERSION-linux-x64.tar.gz && \
    cd node-$NODE_VERSION-linux-x64 && \
    cp -ar bin/* /usr/local/bin && \
    cp -ar include/* /usr/local/include && \
    cp -ar lib/* /usr/local/lib && \
    cp -ar share/* /usr/local/share && \
    rm -rf /tmp/node*

COPY . .

RUN npm install

CMD node index.js
