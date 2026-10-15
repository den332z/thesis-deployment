# Dockerfile for deploying the Flask+PyTorch backend to Render, Railway, or any Docker host.
# This runs the scoring engine with frozen DistilBERT and LSTM model inference on CPU.

FROM python:3.11-slim

# Install system dependencies for PyTorch on CPU
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for layer caching
COPY grooming-detector/grooming-detector-trajectory-pipeline/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy the full project (model weights, configs, pipeline code)
COPY . .

WORKDIR /app/grooming-detector/grooming-detector-trajectory-pipeline/demo_live

# Render/Railway set PORT automatically
ENV PORT=5000
ENV HOST=0.0.0.0
EXPOSE 5000

# Use gunicorn for production (preload so the model loads once)
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT} --timeout 120 --workers 1 --preload app:app"]
