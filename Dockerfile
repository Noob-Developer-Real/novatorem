# syntax=docker/dockerfile:1

FROM python:3.12-slim

# Prevent Python from writing pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies (curl optional, but useful)
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the full project
COPY . .

# Expose the port Gunicorn will run on
EXPOSE 5000

# (Optional but recommended) Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/api/spotify || exit 1

# Start the application with Gunicorn
CMD ["gunicorn", "--workers=2", "--threads=4", "--bind", "0.0.0.0:5000", "api.orchestrator:app"]
