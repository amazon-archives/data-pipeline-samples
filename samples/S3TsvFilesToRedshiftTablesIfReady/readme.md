#Data Pipeline  Load Tab Separated Files in S3 to Redshift if file exists

##About the sample
This pipeline definition when imported would instruct Redshift to load two TSV files from given two S3 location, into two different Redshift Table. Two copy activities are independent, each will start once the input s3 file exists. Table insert mode is OVERWRITE_EXISTING.

##Running this sample
The pipeline requires the following user input point:

1. Redshift connection info
2. The S3 file locations where the input TSV files are located. 
2. Redshift target table names of each S3 file to copy to.
3. Redshift Cluster security group id(s).


## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the [readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.
Redshift Cluster and Table must already exist.
S3 tsv file locations are input for this pipeline, RedshiftCopy activity will start only when input S3 file exists.


## Run this sample pipeline using the AWS CLI

```sh 
  $> aws datapipeline create-pipeline --name s3_if_ready_to_redshift --unique-id s3_if_ready_to_redshift
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
  $> aws datapipeline put-pipeline-definition --pipeline-definition file://S3TsvFilesToRedshiftTablesIfReady.json --pipeline-id <your-pipeline-id-shown-in-last-command> \
  --parameter-values  myRedshiftUsername=<myRedshiftUsername>  \*myRedshiftPassword=<redshift password> \
     myRedshiftDbName=<myRedshiftDbName> \
     myRedshiftSecurityGrpIds=<security group like sg-abc> \
     myRedshiftJdbcConnectStr=<your connection string like jdbc:redshift://example.eaeer.us-east-1.redshift.amazonaws.com:5439/example>\
     myInputTsvFilesS3Loc_1=<s3://myInputTsvFilesS3Loc_1.csv>\
     myDestRedshiftTable_1=<table name for file 1>\
     myInputTsvFilesS3Loc_2=s3://myInputTsvFilesS3Loc_2.csv>\
     myDestRedshiftTable_2=<table name for file 2>\
     myLogUri=<s3://your-log-location> 

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

Licensed under the MIT-0 License.
