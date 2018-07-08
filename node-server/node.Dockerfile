FROM node:8.11

WORKDIR /opt/app

COPY . .

RUN npm install

CMD node index.js
