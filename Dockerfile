FROM python:3.13-slim

WORKDIR /app

# Install dependencies during image build (no network needed at runtime)
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code and pytest suite
COPY src/ ./src/
COPY tests/ ./tests/

EXPOSE 8080

# Start the FastAPI application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]