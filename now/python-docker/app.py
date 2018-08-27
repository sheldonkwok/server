from flask import Flask
from waitress import serve

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
 serve(app)
