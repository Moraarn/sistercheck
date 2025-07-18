# --- Base stage: shared setup ---
FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install dependencies first (layer caching)
COPY requirements*.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# --- Development stage (optional) ---
FROM base AS development
COPY . .
EXPOSE 5001
CMD ["python", "api_server.py"]

# --- Production stage ---
FROM base AS production

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy project files and set ownership
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 5001

# Healthcheck to ensure the server is responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:5001/health')" || exit 1

# Run the app using Gunicorn in production
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "api_server:app"]
