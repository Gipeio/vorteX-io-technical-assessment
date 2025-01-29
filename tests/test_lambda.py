import sys
import os
import json

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from lambda_app.app import lambda_handler

# Case 1: valid message
def test_lambda_handler_valid_message():
    event = {
        "body": json.dumps({"message": "Hello Lambda"})
    }
    context = {}
    
    response = lambda_handler(event, context)
    
    assert response['statusCode'] == 200
    assert response['body'] == '"The received message is: \'Hello Lambda\'"'


# Case 2: no message
def test_lambda_handler_no_message():
    event = {
        "body": json.dumps({})
    }
    context = {}
    
    response = lambda_handler(event, context)
    
    assert response['statusCode'] == 200
    assert response['body'] == '"The received message is: \'\'"'


# Case 3: invalid json
def test_lambda_handler_invalid_json():
    event = {
        "body": "{'message': Hello Lambda}"
    }
    context = {}
    
    response = lambda_handler(event, context)
    
    assert response['statusCode'] == 500
    assert response['body'] == '"Internal Server Error"'
