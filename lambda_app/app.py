"""Entry points for the application."""

import json
import logging
from typing import Union

logger = logging.getLogger()
logger.setLevel('INFO')


def process(message: str) -> str:
    """Process message. The application logic is impleted here.
    Nothing to implement for the assessment.
    """
    return f"The received message is: '{message}'"


JSON = dict[str, Union[int, str, float, 'JSON']]

LambdaEvent = JSON
LambdaContext = object
LambdaOutput = JSON


def lambda_handler(event: LambdaEvent, context: LambdaContext) -> LambdaOutput:  # noqa: ARG001
    """Entry point for Lambda function.

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    -------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

    """

    # Extraction of message from event
    try:
        body = event.get('body', '{}')
        body = json.loads(body)
        message = body.get('message', '')

        # Treatment
        processed_message = process(message)

    # Return with error
    except ValueError:
        logger.exception('Error processing event')
        return {
            'statusCode': 500,
            'body': '"Internal Server Error"',
        }

    # Return without error
    else:
        return {
            'statusCode': 200,
            'body': f'"{processed_message}"',
        }

