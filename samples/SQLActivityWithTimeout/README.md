# Data Pipeline SQL Activity with timeout sample

## Overview

This sample shows how to build a pipeline that uses the SQL activity to execute queries defined in a .sql script file
that is stored on S3. The SQL queries are executed against an RDS mySQL database instance.

The sample also demonstrates setting an explicit timeout on the attempt of the SQL activity (attemptTimeout: "1 hour") in the pipeline definition json file. This field can be set appropriately based on the expected run time of the activity attempt. 

The project provides scripts for setting up the RDS database for the sample, importing a [data set](http://aws.amazon.com/datasets/6468931156960467) (pipeline.json), and destroying the RDS datbase. The project also provides the [pipeline definition file](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-writing-pipeline-definition.html) which is used to create the pipeline and the AWS CLI commands for creating and executing the pipeline. See the instructions below to get started.

*Note: Normal AWS charges apply for the resources created by the script. Make sure to run the teardown script as soon as you are done with the sample.*

## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.

## Step 1: Priming this sample

Run the following commands to run the setup script.

*Setup and teardown scripts are located in the setup directory.
```sh
$> cd <GITCLONE>/data-pipeline-samples/samples/SQLActivityWithTimeout
$> python setup/Setup.py
```

## Step 2: Run this sample pipeline using the AWS CLI

```sh 
  $> aws datapipeline create-pipeline --name sql_activity_pipeline --unique-id sql_activity_pipeline
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
  $> aws datapipeline put-pipeline-definition --pipeline-definition file://pipeline.json --parameter-values
     myS3LogsPath=<s3://your/s3/logs/path> myRDSUsername=<your-rds-username> myRDSPassword=<your-rds-password>
     myRDSId=<your-rds-id> --pipeline-id <Your Pipeline ID> 
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
```sh
  >$ aws datapipeline list-runs --pipeline-id <Your Pipeline ID>
```

You will receive status information on the pipeline. For example... 
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


## Step 3: IMPORTANT! Tear down this sample

*Note: The setup script will provide the teardown command with parameters at end of the execution.*

```sh
$> python setup/Teardown.py --rds-instance-id <rds_instance_id>
```

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

http://aws.amazon.com/asl/
