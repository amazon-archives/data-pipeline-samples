#!/bin/bash

aws s3 cp s3://data-pipeline-samples/kinesis-apache-access-logs/create-table-from-kinesis-stream.q .
aws s3 cp s3://data-pipeline-samples/kinesis-apache-access-logs//write-kinesis-to-s3.q .

S3_LOCATION=$1

#Read iteration count from DynamoDb if exists
result=$(aws dynamodb get-item --table-name MyEMRKinesisTableIteration --key '{"Hash":{"S": "IterationCount"}}' --attributes-to-get "Count")
if [ -z "$result" ];
then
    ITERATION_COUNT=0
else
    ITERATION_COUNT=$(echo $result | grep "S" | sed 's/[^0-9]//g' )    
fi

echo "Processing with iteration count $ITERATION_COUNT"

#Run hive scripts
hive -hivevar s3Location=$S3_LOCATION -f create-table-from-kinesis-stream.q

echo "Completed table creation"

hive -hivevar iterationNo=$ITERATION_COUNT -f write-kinesis-to-s3.q

ITERATION_COUNT=$((ITERATION_COUNT+1))

echo "Writing iteration count as $ITERATION_COUNT"

#Write iteration count to DynamoDb
aws dynamodb put-item --table-name MyEMRKinesisTableIteration --item {\"Hash\":{\"S\":\"IterationCount\"}\,\"Count\":{\"S\":\"$ITERATION_COUNT\"}}
