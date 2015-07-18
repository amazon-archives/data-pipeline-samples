#!/bin/bash

cli_root=$1
definition="file://`pwd`/SqoopRDSToS3Sample.json"
timestamp=`date +%m-%d-%Y-%T | sed "s/:/-/g"`
region="us-east-1"

# Create a new Data Pipeline and save its ID
pipelineId=`$cli_root/bin/aws datapipeline create-pipeline --region $region --name "Sqoop Sample Activity" --unique-id sqoop_sample_activity_$timestamp | grep pipelineId | cut -d: -f2 | sed "s/ //g" | sed "s/\"//g"`

if [ "$pipelineId" = "" ]
then
    echo "Pipeline creation failed (this is unexpected)."
    exit 1
fi

echo "Data Pipeline $pipelineId successfully created"

# Add a pipeline definition to the new pipeline
error=`$cli_root/bin/aws datapipeline put-pipeline-definition --pipeline-id $pipelineId --pipeline-definition $definition --region $region | grep errored | cut -d: -f2 | grep -o true`

if [ "$error" = "true" ]
then
    echo "There was an error validating the definition file for Pipeline $pipelineId."
    exit 1
fi

echo "Definition $definition has been successfully added to Pipeline $pipelineId"

# Activate the pipeline
$cli_root/bin/aws datapipeline activate-pipeline --pipeline-id $pipelineId --region $region

echo "Pipeline $pipelineId is now active."
