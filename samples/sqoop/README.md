# Data Pipeline Sqoop Sample

## Overview

This sample makes it easy to setup a pipeline that uses [Sqoop](http://sqoop.apache.org/) to move data to from a MySql database hosted in RDS to a Redshift database cluster. S3 is used to stage the data between the databases.

The project provides scripts for setting up the resources for the pipeline, installing the [data set](http://aws.amazon.com/datasets/6468931156960467), and destroying the resources. The project also provides the [pipeline definition file](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-writing-pipeline-definition.html) which is used to create the pipeline and the AWS CLI commands for creating and executing the pipeline. See the instructions below to get started.

*Note: Normal AWS charges apply for the resources created by the script. Make sure to run the teardown script as soon as you are done with the sample.*

## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.

You must also provide the S3Path of a S3 bucket with write permissions. See [here](http://docs.aws.amazon.com/AmazonS3/latest/UG/CreatingaBucket.html) for instructions on how to create an S3 bucket.

Finally, you must install the [Python SDK for AWS](http://boto3.readthedocs.org/en/latest/guide/quickstart.html).
```
$> pip install boto3
```

## Step 1: Priming this sample

Run the following commands to give the setup script executable permissions and run the script. The AWS resources that will be created are a Redshift database, RDS MySQL database, and optionally an S3 bucket.

The script takes an *optional* parameter for an S3 path for staging data between RDS and Redshift. If you choose to provide your own S3 path, the bucket must be in the same region as what is set for your AWS CLI configuration.  In addition, this path cannot be an existing path as Sqoop is expected to create it in order to place the data it extracts from RDS (if the path you provide already exists, the setup process will issue an error message and exit).  Finally, please make sure the S3 bucket has a policy that allows data writes to it.  

If the path is not provided, the script will create the S3 bucket for you.

*Setup and teardown scripts are located in the setup directory under the sqoop directory in the samples directory.*

```
$> cd <GITCLONE>/data-pipeline-samples/samples/sqoop/setup
$> python Setup.py [s3://optional/path/to/s3/location]
$> cd ..   # get sample directory where you will find the pipeline sample 
```

## Step 2: Run this sample pipeline using the AWS CLI

  ```
  $> aws datapipeline create-pipeline --name sqoop_pipeline --unique-id sqoop_pipeline

  # You receive a pipeline activity like this. 
  #   -----------------------------------------
  #   |             CreatePipeline             |
  #   +-------------+--------------------------+
  #   |  pipelineId |  <Your Pipeline ID>      |
  #   +-------------+--------------------------+

  # now upload the pipeline definition 

  $> aws datapipeline put-pipeline-definition --pipeline-id <Your Pipeline ID> --pipeline-definition file://sqoop.json --parameter-values myS3StagingPath=<s3://your/s3/staging/path> myRedshiftEndpoint=<redshift_endpoint> myRdsEndpoint=<rds_endpoint>

  # You receive a validation messages like this

  #   ----------------------- 
  #   |PutPipelineDefinition|
  #   +-----------+---------+
  #   |  errored  |  False  |
  #   +-----------+---------+

  # now activate the pipeline
  $> aws datapipeline activate-pipeline --pipeline-id <Your Pipeline ID>
```

Check the status of your pipeline 
```sh
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
  #   3.  DataNodeId_7EqZ7                                    2015-07-29T01:06:17  WAITING_ON_DEPENDENCIES
  #       @DataNodeId_7EqZ7_2015-07-29T01:06:17               2015-07-29T01:06:22
  #
  #   4.  DataNodeId_ImmS9                                    2015-07-29T01:06:17  FINISHED
  #       @DataNodeId_ImmS9_2015-07-29T01:06:17               2015-07-29T01:06:20  2015-07-29T01:06:21
  #
  #   5.  ActivityId_wQhxe                                    2015-07-29T01:06:17  WAITING_FOR_RUNNER
  #       @ActivityId_wQhxe_2015-07-29T01:06:17               2015-07-29T01:06:20

```

Let the pipeline complete, then connecto to the Redshift cluster with a sql client and query your data. 

```sh
  $> psql "host=<endpoint> user=<userid> dbname=<databasename> port=<port> sslmode=verify-ca sslrootcert=<certificate>"
  $  psql> SELECT * FROM songs;
```

## Step 3: IMPORTANT! Tear down this sample

Run the following command to give the script executable permissions and to run the script. The script will destroy the AWS resources created by the setup script.

*Note: The setup script will provide the teardown command with parameters at end of the execution.*

```
$> cd setup
$> python Teardown.py <rds_instance_id> <redshift_cluster_id> [s3://optional/path/to/s3/bucket/created/by/setup]
```

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

http://aws.amazon.com/asl/
