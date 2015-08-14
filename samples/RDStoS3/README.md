# Data Pipeline RDStoS3 Sample

## Overview

This sample shows how to build a pipeline that outputs a MySQL table in csv format from a RDS database to an S3 bucket.

The project provides scripts for setting up the resources for the pipeline, installing the [data set](http://aws.amazon.com/datasets/6468931156960467), and destroying the resources. The project also provides the [pipeline definition file](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-writing-pipeline-definition.html) which is used to create the pipeline and the AWS CLI commands for creating and executing the pipeline. See the instructions below to get started.

*Note: Normal AWS charges apply for the resources created by the script. Make sure to run the teardown script as soon as you are done with the sample.*

## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.

You must also provide the S3Path of a S3 bucket with write permissions. See [here](http://docs.aws.amazon.com/AmazonS3/latest/UG/CreatingaBucket.html) for instructions on how to create an S3 bucket.

## Step 1: Priming this sample

Run the following commands to run the setup script. The AWS resources that will be created are a RDS MySQL database and optionally an S3 bucket.

The script takes an *optional* parameter for an S3 path for outputting the data from S3. If you choose to provide your own S3 path, the bucket must be in the same region as what is set for your AWS CLI configuration.  Finally, please make sure the S3 bucket has a policy that allows data writes to it.  

If the path is not provided, the script will create the S3 bucket for you.

*Setup and teardown scripts are located in the setup directory under the sqoop directory in the samples directory.*
```
$> cd <GITCLONE>/data-pipeline-samples/samples/RDStoS3
$> python setup/Setup.py --s3-path [s3://optional/path/to/s3/location]
```

## Step 2: Run this sample pipeline using the AWS CLI

```sh 
  $> aws datapipeline create-pipeline --name rds_to_s3_pipeline --unique-id rds_to_s3_pipeline
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
  $> aws datapipeline put-pipeline-definition --pipeline-definition file://RDStoS3Pipeline.json --parameter-values myOutputS3Path=<s3://your/s3/output/path> myS3LogsPath=<s3://your/s3/logs/path> myRDSPassword=<your-rds-password> myRDSUsername=<your-rds-username> myRDSTableName=<your-rds-table-name> myRDSConnectStr=<your-rds-connection-string> --pipeline-id <Your Pipeline ID> 
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
  #       Name                                                Scheduled Start      Status
  #       ID                                                  Started              Ended
  #---------------------------------------------------------------------------------------------------
  #   1.  ActivityId_6OGtu                                    2015-07-29T01:06:17  WAITING_ON_DEPENDENCIES
  #       @ActivityId_6OGtu_2015-07-29T01:06:17               2015-07-29T01:06:20
  #
  #   2.  ResourceId_z9RNH                                    2015-07-29T01:06:17  CREATING
  #       @ResourceId_z9RNH_2015-07-29T01:06:17               2015-07-29T01:06:20
  #
  #       @ActivityId_wQhxe_2015-07-29T01:06:17               2015-07-29T01:06:20
```

Let the pipeline complete, then check the output S3 bucket for the output csv file.

## Step 3: IMPORTANT! Tear down this sample

*Note: The setup script will provide the teardown command with parameters at end of the execution.*

```
$> python setup/Teardown.py --rds-instance-id <rds_instance_id> -s3-path [s3://optional/path/to/s3/bucket/created/by/setup]
```

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

http://aws.amazon.com/asl/
