#!/bin/bash

# Variables
LAMBDA_PORT="5432"
EVENT_FILE="events/event.json"

# Check if the event file exists
if [ ! -f "$EVENT_FILE" ]; then
  echo "Error: Event file $EVENT_FILE not found."
  exit 1
fi

# Read the JSON payload from the event file
REQUEST_JSON=$(cat "$EVENT_FILE")

# Invoke the Lambda function using curl
echo "Invoking Lambda function with payload from $EVENT_FILE..."
response=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d "$REQUEST_JSON" \
  http://localhost:${LAMBDA_PORT}/2015-03-31/functions/function/invocations)

# Extract the HTTP status code and response body
http_code=$(echo "$response" | tail -n 1)
http_body=$(echo "$response" | sed '$d')

# Display the Lambda function's response
echo "Lambda response body:"
echo "$http_body"