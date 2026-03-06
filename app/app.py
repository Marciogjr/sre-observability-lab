from flask import Flask
import logging

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)

@app.route("/")
def home():
    app.logger.info("Request recebida")
    return "SRE Observability Lab OK"

@app.route("/error")
def error():
    app.logger.error("Erro proposital para teste")
    return "Erro gerado", 500

@app.route("/health")
def health():
    return "ok"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)