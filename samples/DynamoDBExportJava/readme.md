# Data Pipeline DynamoDB Export Java Sample

## Overview

This sample makes it easy to create a pipeline that uses the latest DynamoDB export template EMR activity. You provide 
parameters and the tool will create the pipeline and run and monitor it once so you can verify that it is healthy.

This sample also provides an example application using the AWS Data Pipeline Java SDK. It demonstrates how to
create, run and monitor a pipeline.

## Prerequisites

You must have the AWS CLI and default IAM roles setup in order to run the sample. Please see the 
[readme](https://github.com/awslabs/data-pipeline-samples) for the base repository for instructions how to do this.


## Getting started

Build: mvn clean package <br/> <br/>
View parameters description: java -jar path/to/DynamoDBExportSample-0.1.jar help <br/> <br/>
Run: java -jar path/to/DynamoDBExportSample-0.1.jar  <-yourParam foo>

## Example

Create and run on a pipeline that runs once per day:

java -jar /Users/foobar/DynamoDBExportJava/target/DynamoDBExportSample-0.1.jar -credentialsFile 
/Users/foobar/.aws/credentials -myDDBTableName footable -myOutputS3Location s3://foobar/ddb-exports -schedule daily 
-myLogsS3Location s3://foobar/logs -myDDBRegion us-east-1

Create and run on a pipeline that runs once:

java -jar /Users/foobar/DynamoDBExportJava/target/DynamoDBExportSample-0.1.jar -credentialsFile 
/Users/foobar/.aws/credentials -myDDBTableName footable -myOutputS3Location s3://foobar/ddb-exports -schedule once 
-myLogsS3Location s3://foobar/logs -myDDBRegion us-east-1

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for 
production environments. Users should carefully inspect code samples before running them.

Use at your own risk.

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the 
License. A copy of the License is located at

http://aws.amazon.com/asl/
