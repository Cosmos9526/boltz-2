#!/bin/bash

echo "Starting the model server..."

# Run FastAPI server
exec uvicorn app:app --host 0.0.0.0 --port 8000
