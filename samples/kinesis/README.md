![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/setup/logo/datapipelinelogo.jpeg)

Process a Kinesis stream of Apache access logs using EMR
=====================
This sample sets up a Data Pipeline to run an analysis on a kinesis stream every 15 minutes and store the result in S3. This requires the setup from the EMR [documentation](http://docs.aws.amazon.com/ElasticMapReduce/latest/DeveloperGuide/emr-kinesis.html).

# Running the sample

##Setting up your resources

The setup script will:
- create a Kinesis stream named AccessLogStream
- create a DynamoDb table called MyEMRKinesisTable 
- create a DynamoDb table called MyEMRKinesisTableIteration
- download a kinesis stream appender for sample apache access logs
 
```sh
 $> setup/setup-script.sh
```
##Populating your stream

You can push sample data to your stream by running

```sh
 $> setup/append-to-stream.sh
```

##Setting up the pipeline

The instructions at https://github.com/awslabs/data-pipeline-samples tell you how to create, setup, and activate a pipeline. 

```sh
 $> aws datapipeline create-pipeline --name kinesis_apache_access_logs --unique-id kinesis_apache_access_logs
 $> aws datapipeline put-pipeline-definition --pipeline-id df-0554887H4KXKTY59MRJ --pipeline-definition file://samples/kinesis/kinesis-to-s3.json --parameter-values myS3LogsPath="<your s3 logging path>" myS3Output="<your s3 output path>"
 $> aws datapipeline activate-pipeline --pipeline-id df-0554887H4KXKTY59MRJ
```
