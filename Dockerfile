FROM public.ecr.aws/lambda/python:3.12

WORKDIR /var/task

COPY lambda_app/ lambda_app/

# python 'requirements.txt' file to insall the Python dependencies with pip
# can be generated using 'poetry export --without-hashes > lambda_app/requirements.txt'
COPY lambda_app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

CMD ["lambda_app.app.lambda_handler"]