#Data Pipeline  Load Tab Separated Files in S3 to Redshift 

##About the sample
This pipeline definition when imported would instruct Redshift to load TSV files under the specified S3 Path into a specified Redshift Table. Table insert mode is OVERWRITE_EXISTING.

##Running this sample
The pipeline requires the following user input point:

1. The S3 folder where the input TSV files are located. 
2. Redshift connection info along with the target table name.
3. Redshift Cluster security group id(s).


## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.
TSV files under a S3 folder path is the input for this pipeline. Redshift Cluster and Table must already exist.



## Run this sample pipeline using the AWS CLI

```sh 
  $> aws datapipeline create-pipeline --name copy_tsv_to_redshift_pipeline --unique-id copy_tsv_to_redshift_pipeline
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
     myInputTsvFilesS3Loc=<s3://tsv-files-insert-loc> myRedshiftJdbcConnectStr=<jdbc:postgresql://endpoint:port/database?tcpKeepAlive=true> myRedshiftUsername=<user> myRedshiftPassword=<your-red-password>
     myRedshiftTableName=<target-redshift-tablename> myRedshiftSecurityGrpIds=<sg-blah> --pipeline-id <Your Pipeline ID> 
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

You will receive status information on the pipeline. 


## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

http://aws.amazon.com/asl/
