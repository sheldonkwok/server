FROM python:3.7-alpine

RUN pip install flask waitress

COPY . .

ENTRYPOINT ["python", "app.py"]
