from __future__ import print_function

import json
import urllib
import boto3

print('Loading function')

client = boto3.client('datapipeline')
pipeline_id = 'df-123456789'

def lambda_handler(event, context):
    try:
        response = client.activate_pipeline(pipelineId=pipeline_id)
        return response
    except Exception as e:
        print(e)
        raise e
