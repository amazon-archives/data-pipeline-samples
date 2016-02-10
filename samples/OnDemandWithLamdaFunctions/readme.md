#### This sample shows how to create a Lamda function that responds to S3 create object events on an S3 bucket and/or a Cloudwatch Scheduled Event.

The following Python code defines an AWS Lamda function to run an ondemand pipeline. This code is in a file called lamda_function.py. You simply need to set the ``pipeline_id`` variable with the id of your on-demand pipeline.

```python
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
```
### Step 1: Create the on-demand pipeline
*Make sure the pipeline is created in a region that supports Lamda.*

Create the pipeline:

```sh 
  $> aws datapipeline create-pipeline --name on_demand_lamda --unique-id on_demand_lamda
```

Upload the pipeline definition:

```sh
  $> aws datapipeline put-pipeline-definition --pipeline-definition file://ondemand.json \
  --parameter-values myS3LogsPath=<s3://your/s3/logs/path> --pipeline-id <Your Pipeline ID> 
```

Activate the pipeline to make sure it runs sucessfully:

```sh
  $> aws datapipeline activate-pipeline --pipeline-id <Your Pipeline ID>
```

Check the status of your pipeline:
```
  >$ aws datapipeline list-runs --pipeline-id <Your Pipeline ID>
```

### Step 2: Create the Lamda function


```sh
  >$ aws lambda create-function --function-name <fn-name> --runtime python2.7 \
  --role <role-arn-that-allows-data-pipeline-activate> --handler lambda_function.lambda_handler \
  --zip-file file:///zip-with-lamda-fn-code.zip --publish --timeout 10
```

See this link for reference on the Lamda create-function command: 
http://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html

### Step 3: Set-up an event source for the Lamda funtion

##### Set-up an S3 bucket to call the Lamda function when objects are created

Create the s3 bucket:

```sh
  $> aws s3 mb <s3://bucket>
```

Run the following Lambda add-permission command to grant Amazon S3 service principal permissions to perform the lambda:InvokeFunction action:

```sh
  $> aws lambda add-permission --function-name <function-name> \
--region <region> --statement-id <some-unique-id> --action "lambda:InvokeFunction" \
--principal s3.amazonaws.com --source-arn <arn:aws:s3:::sourcebucket> \
--source-account <bucket-owner-account-id> --profile adminuser
```

See this link for reference on the lamda add-permission command:
http://docs.aws.amazon.com/cli/latest/reference/lambda/add-permission.html

Add the notification on S3 and have it call the Lamda function:

\*Make sure your notification configuration contains ``s3:ObjectCreated:*`` events

```sh
  $> aws s3api put-bucket-notification --bucket <your bucket name> --notification-configuration <your-cloud-function notification-configuration>
```

See this link for reference on the s3api put-bucket-notification command:  
http://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-notification.html

Upload a file to the S3 bucket and make validate the lamda function activated your pipeline:

```sh
  $> aws s3 cp <test.txt> <s3://bucket/test.txt>
  $> aws datapipeline list-runs --pipeline-id <Your Pipeline ID>
```

##### OR Add a CRON schedule using Cloudwatch Scheduled Events

This is only possible in the Lamda console. Instructions here: http://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html
