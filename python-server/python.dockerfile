FROM python:3.7.0

ENV FLASK_APP main.py

WORKDIR /opt/app

COPY . .

RUN pip install -r requirements.txt

CMD flask run --host=0.0.0.0
