# Stage 1 - build
FROM python:3.11-slim AS builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2 - runtime
FROM python:3.11-slim

RUN useradd -m appuser

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local
COPY app/ .

ENV PATH=/home/appuser/.local/bin:$PATH

USER appuser

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app"]