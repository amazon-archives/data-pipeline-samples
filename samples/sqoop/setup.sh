#!/bin/bash

aws_account_id=`aws iam get-user | grep UserId | cut -d: -f2 | sed "s/ //g" | \
sed "s/\"//g" | sed "s/,//g"`

echo "Using AWS account $aws_account_id"

if ! [ -d $1 ]
then
    echo "Please provide an S3 folder for staging data between RDS and Redshift."
    echo "You must have read AND write access to this folder."
    exit 1
fi
s3_staging_dir=$1
db_security_group="aws_data_pipeline_sqoop_sample_security_group"

DBID="RDS"`cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
CLUSTERIDPREFIX=Cluster-
CLUSTERID=$CLUSTERIDPREFIX`cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
MASTERUSERNAME=dplcustomer
MASTERPASSWORD=Dplcustomer1
RDSDBNAME=millionsongs
STORAGE=5

# create security group for rds instance
res=`aws rds describe-db-security-groups | grep $db_security_group`
if [ "$res" = "" ]
then
    aws rds create-db-security-group --db-security-group-name $db_security_group --db-security-group-description "Sample group for RDS example"
    aws rds authorize-db-security-group-ingress --db-security-group-name $db_security_group --ec2-security-group-name "elasticmapreduce-master" \
    --ec2-security-group-owner-id $aws_account_id
    aws rds authorize-db-security-group-ingress --db-security-group-name $db_security_group --ec2-security-group-name "elasticmapreduce-slave" \
    --ec2-security-group-owner-id $aws_account_id
fi
    
# create rds instance
echo "Creating RDS db instance with id $DBID"
json=`aws rds create-db-instance --db-instance-identifier $DBID --db-instance-class db.m1.small --engine MySQL \
--allocated-storage $STORAGE --master-username $MASTERUSERNAME --master-user-password $MASTERPASSWORD \
--db-security-groups $db_security_group --db-name $RDSDBNAME --backup-retention-period 0`

# create redshift instance
json=`echo "Creating redshift cluster id $CLUSTERID"
aws redshift create-cluster --cluster-type single-node --node-type dc1.large --master-username $MASTERUSERNAME \
--master-user-password $MASTERPASSWORD --cluster-identifier $CLUSTERID --cluster-security-groups default`

while true; do
    rds_hostname=`aws rds describe-db-instances --db-instance-identifier $DBID | grep -A 2 Endpoint | grep Address | cut -d: -f2 | sed "s/ //g" | sed "s/\"//g"`
    if ! [ "$rds_hostname" = "" ]
    then
        break
    fi
    echo "RDS instance still initializing ..."
    sleep 30
done

echo "Please retain the RDS DB instance ID ($DBID) for the tear down procedure."
echo "Hostname is $rds_hostname"

while [ "$redshift_hostname" = "" ]
do
    redshift_hostname=`aws redshift describe-clusters --cluster-identifier $CLUSTERID | grep -A 2 Endpoint | grep Address | cut -d: -f2 | sed 's/ //g' | sed 's/\"//g'`
    if ! [ "$redshift_hostname" = "" ]
    then
        break
    fi
    echo "Redshift instance still initializing ..."
    sleep 30
done
echo "Please retain the Redshift cluster ID ($CLUSTERID) for the tear down procedure."
echo "Redshift hostname is $redshift_hostname"

echo "You can execute teardown.sh $DBID $CLUSTERID to clean up the resources created for this sample."

# Create a pipeline to set up the RDS table
timestamp=`date +%m-%d-%Y-%T | sed "s/:/-/g"`
pipelineId=`aws datapipeline create-pipeline --name "Sqoop Sample Activity" --unique-id sqoop_sample_activity_$timestamp | grep pipelineId | cut -d: -f2 | sed "s/ //g" | sed "s/\"//g"`

if [ "$pipelineId" = "" ]
then
    echo "Pipeline creation failed (this is unexpected)."
    exit 1
fi

echo "Data Pipeline $pipelineId successfully created"
# Put definition
error=`aws datapipeline put-pipeline-definition --pipeline-id $pipelineId --pipeline-definition file://`pwd`/setup.json --parameter-values myRdsEndpoint="$rds_hostname" myRdsDatabase="millionsongs" myRdsTable="songs" myS3Input="s3://data-pipeline-samples/sqoop-activity/sqoop-sample-input.csv" myRdsDbUsername="dplcustomer" myRdsDbPassword="Dplcustomer1" myRdsTableCreate="create table songs (track_id varchar(512) primary key not null, title text, song_id text, release_name text, artist_id text, artist_mbid text, artist_name text, duration float, artist_familiarity float, artist_hotness float, year integer)"`

if [ "$error" = "true" ]
then
    echo "There was an error validating the definition file for Pipeline $pipelineId."
    exit 1
fi

echo "Definition $definition has been successfully added to Pipeline $pipelineId"

# Activate
aws datapipeline activate-pipeline --pipeline-id $pipelineId

echo "Pipeline $pipelineId is now active."

while true; do
   # Check for pipeline completion
   state=`aws datapipeline describe-pipelines --pipeline-id $pipelineId | grep -B 1 @pipelineState | grep -o FINISHED`
   if [ "$state" = "FINISHED" ]
   then
      break;
   fi
   echo "Waiting for all resources to be available ..."
   sleep 30
done
