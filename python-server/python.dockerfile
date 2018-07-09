FROM python:3.7.0

ENV FLASK_APP main.py

WORKDIR /opt/app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY main.py main.py

CMD flask run --host=0.0.0.0
