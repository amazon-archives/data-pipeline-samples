# Data Pipeline InvokeLambda Sample

## Overview

This sample shows how to build a Shell Command Activity pipeline that invokes AWS Lambda function. 

## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.

## Run this sample pipeline using the AWS CLI

```sh 
  $> aws datapipeline create-pipeline --name invoke_lambda_pipeline --unique-id invoke_lambda_pipeline
```

You receive a pipelineId like this. 
```sh
  #   -----------------------------------------
  #   |             CreatePipeline             |
  #   +-------------+--------------------------+
  #   |  pipelineId |  <Your Pipeline ID>      |
  #   +-------------+--------------------------+
```

```sh
  $> aws datapipeline put-pipeline-definition --pipeline-definition file://invokelambda.json --parameter-values myLambdaFunction=<your lambda function>  myS3LogsPath=s3://<s3 bucket>/path --pipeline-id <Your Pipeline ID> 
```

You receive a validation messages like this
```sh
  #   ----------------------- 
  #   |PutPipelineDefinition|
  #   +-----------+---------+
  #   |  errored  |  False  |
  #   +-----------+---------+
```

Now activate the pipeline
```sh
  $> aws datapipeline activate-pipeline --pipeline-id <Your Pipeline ID>
```

Check the status of your pipeline 
```
  >$ aws datapipeline list-runs --pipeline-id <Your Pipeline ID>
```

You will receive status information on the pipeline.  
```sh
       Name                                                Scheduled Start      Status                 
       ID                                                  Started              Ended              
---------------------------------------------------------------------------------------------------
   1.  Invoke_Lambda_Activity                              2016-03-23T18:40:31  WAITING_FOR_RUNNER     
       @Invoke_Lambda_Activity_2016-03-23T18:40:31         2016-03-23T18:40:35                     

   2.  New_EC2Instance                                     2016-03-23T18:40:31  CREATING               
       @New_EC2Instance_2016-03-23T18:40:31                2016-03-23T18:40:36                     

```


## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Licensed under the MIT-0 License.
