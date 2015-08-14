#!/bin/bash

# Create Kinesis stream for sample
aws kinesis create-stream --stream-name AccessLogStream --shard-count 2

# Create DynamoDb table required by EMR to process Kinesis
aws dynamodb create-table --table-name MyEMRKinesisTable --attribute-definitions AttributeName=HashKey,AttributeType=S AttributeName=RangeKey,AttributeType=S --key-schema AttributeName=HashKey,KeyType=HASH AttributeName=RangeKey,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10

#Create DynamoDb table to maintain iterations on Kinesis processing by EMR
aws dynamodb create-table --table-name MyEMRKinesisTableIteration --attribute-definitions AttributeName=Hash,AttributeType=S  --key-schema AttributeName=Hash,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

# Download sample kinesis stream appender
wget http://emr-kinesis.s3.amazonaws.com/publisher/kinesis-log4j-appender-1.0.0.jar

# Download sample access logs
wget http://elasticmapreduce.s3.amazonaws.com/samples/pig-apache/input/access_log_1
