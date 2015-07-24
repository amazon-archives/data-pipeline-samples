# Data Pipeline Sqoop Sample

## Overview

This sample makes it easy to setup a pipeline that uses [Sqoop](http://sqoop.apache.org/) to move data to from a MySql database hosted in RDS to a Redshift database cluster. S3 is used to stage the data between the databases.

The project provides scripts for setting up the resources for the pipeline, installing the [data set](http://aws.amazon.com/datasets/6468931156960467), and destroying the resources. The project also provides the [pipeline definition file](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-writing-pipeline-definition.html) which is used to create the pipeline and the AWS CLI commands for creating and executing the pipeline. See the instructions below to get started.

*Note: Normal AWS charges apply for the resources created by the script. Make sure to run the teardown script as soon as you are done with the sample.*

## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.

You must also provide the S3Path of a S3 bucket with write permissions. See [here](http://docs.aws.amazon.com/AmazonS3/latest/UG/CreatingaBucket.html) for instructions on how to create an S3 bucket.

## Step 1: Setup resources and data

Run the following script to set-up the databases and source data in your AWS account.

The script takes an *optional* parameter for an S3 path for staging data between RDS and Redshift. If you choose to provide your own S3 path, the bucket must be in the same region as what is set for your AWS CLI configuration.

If the path is not provided, the script will create the S3 bucket for you.
```
$> ./setup.sh [s3://optional/path/to/s3/bucket]
```
*Note: Make sure the script has executable permissions.*

```
$> chmod +x setup.sh
```

## Step 2: Run the pipeline using AWS CLI commands

  ```
  $> aws datapipeline create-pipeline --name sqoop_pipeline --unique-id <unique_id>

  # You receive a pipeline activity like this. 
  #   -----------------------------------------
  #   |             CreatePipeline             |
  #   +-------------+--------------------------+
  #   |  pipelineId |  df-0554887H4KXKTY59MRJ  |
  #   +-------------+--------------------------+

  # now upload the pipeline definition 

  $> aws datapipeline put-pipeline-definition --pipeline-id df-0554887H4KXKTY59MRJ --pipeline-definition file://samples/sqoop/sqoop.json --parameter-values myS3StagingPath=<s3://your/s3/bucket/path> myRedshiftEndpoint=<redshift_endpoint> myRDSEndpoint=<rds_endpoint>

  # You receive a validation messages like this

  #   ----------------------- 
  #   |PutPipelineDefinition|
  #   +-----------+---------+
  #   |  errored  |  False  |
  #   +-----------+---------+

  # now activate the pipeline
  $> aws datapipeline activate-pipeline --pipeline-id df-0554887H4KXKTY59MRJ

  #check the status of your pipeline 

  $> aws datapipeline list-runs --pipeline-id df-0554887H4KXKTY59MRJ

  #          Name                                                Scheduled Start      Status
  #          ID                                                  Started              Ended
  #   ---------------------------------------------------------------------------------------------------
  #      1.  A_Fresh_NewEC2Instance                              2015-07-19T22:48:30  RUNNING
  #          @A_Fresh_NewEC2Instance_2015-07-19T22:48:30         2015-07-19T22:48:35
  #   
  #      2.  ...

```

## Step 3: Tear down 

Run the following script to destroy the databases and optionally the S3 bucket (only if it was created by setup.sh).

*Note: The setup script will provide the teardown command with parameters at end of the execution.*

```
$> ./teardown.sh <rds_instance_id> <redshift_cluster_id> [s3://optional/path/to/s3/bucket/created/by/setup]
```

*Note: Make sure the script has executable permissions.*

```
$> chmod +x teardown.sh
```

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

http://aws.amazon.com/asl/
