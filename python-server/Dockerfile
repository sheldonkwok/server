FROM ubuntu:16.04

ENV FLASK_APP main.py

RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y python curl \
  && cd /tmp \
  && curl -sS -O https://bootstrap.pypa.io/get-pip.py \
  && python get-pip.py \
  && pip install --upgrade pip \
  && pip install --upgrade awscli \
  && cd / \
  && rm -rf /tmp/get-pip.py

WORKDIR /opt/app

COPY . .

RUN pip install -r requirements.txt

CMD flask run --host=0.0.0.0
