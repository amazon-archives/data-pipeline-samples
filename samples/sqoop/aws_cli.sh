#!/bin/bash

rds_hostname=$1
s3_staging_dir=$2
redshift_hostname=$3

timestamp=`date +%m-%d-%Y-%T | sed "s/:/-/g"`

definition="sqoop.json"

# Create a new Data Pipeline and save its ID
pipelineId=`aws datapipeline create-pipeline --name "Sqoop Sample Activity" --unique-id sqoop_sample_activity_$timestamp | grep pipelineId | cut -d: -f2 | sed "s/ //g" | sed "s/\"//g"`

if [ "$pipelineId" = "" ]
then
    echo "Pipeline creation failed (this is unexpected)."
    exit 1
fi

echo "Data Pipeline $pipelineId successfully created"

definition_to_submit="file://`pwd`/$definition"
# Add a pipeline definition to the new pipeline
error=`aws datapipeline put-pipeline-definition --pipeline-id $pipelineId --pipeline-definition $definition_to_submit --parameter-values myRdsEndpoint="$rds_hostname" myRdsDatabase="millionsongs" myRdsTable="songs" myS3Input="s3://data-pipeline-samples/sqoop-activity/sqoop-sample-input.csv" myRdsDbUsername="dplcustomer" myRdsDbPassword="Dplcustomer1" | grep errored | cut -d: -f2 | grep -o true`

if [ "$error" = "true" ]
then
    echo "There was an error validating the definition file for Pipeline $pipelineId."
    exit 1
fi

echo "Definition $definition has been successfully added to Pipeline $pipelineId"

# Activate the pipeline
aws datapipeline activate-pipeline --pipeline-id $pipelineId

echo "Pipeline $pipelineId is now active."
