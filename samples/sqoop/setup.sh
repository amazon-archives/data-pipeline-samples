#!/bin/bash

# We need the AWS account ID to create an RDS DB instance
aws_account_id=`aws iam get-user | grep UserId | cut -d: -f2 | sed "s/ //g" | \
sed "s/\"//g" | sed "s/,//g"`

# echo "Using AWS account $aws_account_id"

s3_staging_path=
use_customer_s3="false"
customer_location=`cat ~/.aws/config | grep region | cut -d= -f2 | sed "s/ //g"`
if [ -z "$1" ]
then
    echo "No S3 staging path given so we will create a temporary staging folder for you."
    tmp_s3_staging_bucket="sqoop.sample."`cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 | tr [:upper:] [:lower:]`
    s3_staging_bucket=`echo $tmp_s3_staging_bucket | sed "s/\./-/g"`
    s3_staging_path="s3://$s3_staging_bucket/staging"
    # Ensure the temp bucket is created in the same region as where Redshift will be created.
    if [ "$customer_location" = "us-east-1" ]; then
        aws s3api create-bucket --bucket $s3_staging_bucket
    else
        aws s3api create-bucket --bucket $s3_staging_bucket --create-bucket-configuration LocationConstraint="$customer_location"
    fi
else
    # First, make sure the S3 path is in the same region as Redshift.
    # Otherwise, Redshift won't be able to read data from S3.
    s3_staging_path=$1
    schema=`echo $s3_staging_path | grep -o -e "^s3://"`
    if [ "$schema" != "s3://" ]; then
        echo "Please provide a valid s3 path starting with s3://<bucket>/<prefix>."
        exit 1
    fi
    s3_staging_bucket=`echo $s3_staging_path | sed "s/s3:\/\///g" | cut -d/ -f1`
    s3_location=`aws s3api get-bucket-location --bucket $s3_staging_bucket | grep LocationConstraint | cut -d: -f2 | sed "s/ //g" | sed "s/\"//g"`
    if [ "$s3_location" = "$customer_location" ]; then
        echo "Valid S3 path"
    elif [ "$s3_location" = "null" ] && [ "$customer_location" = "us-east-1" ]; then
        echo "Valid S3 path"
    else 
        echo "You must use an S3 bucket which was created in the same region as the one used by your AWS CLI ($customer_location)."
        echo "$s3_staging_bucket is in $s3_location."
    fi
    # Make sure the path does not yet exist (Sqoop will create it)
    res=`aws s3 ls $s3_staging_path`
    if [ "$res" != "" ]; then
        echo "$s3_staging_path already exists! Please provide a new S3 path."
        exit 1
    fi 
    use_customer_s3="true"    
fi

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
setup_definition="file://`pwd`/setup.json"
error=`aws datapipeline put-pipeline-definition --pipeline-id $pipelineId --pipeline-definition $setup_definition --parameter-values myRdsEndpoint="$rds_hostname" myRdsDatabase="millionsongs" myRdsTable="songs" myS3Input="s3://data-pipeline-samples/sqoop-activity/sqoop-sample-input.csv" myRdsDbUsername="dplcustomer" myRdsDbPassword="Dplcustomer1" myRdsTableCreate="create table songs (track_id varchar(512) primary key not null, title text, song_id text, release_name text, artist_id text, artist_mbid text, artist_name text, duration float, artist_familiarity float, artist_hotness float, year integer)"`

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
      echo "Pipeline $pipelineId is now completed."
      break;
   fi
   echo "Waiting for all resources to be available ..."
   sleep 30
done

echo ""
echo "Set-up complete! You are now ready to proceed with the Sqoop Sample."
echo "Please refer to the sample README for instructions on how to run this sample."
echo "**************************************************"
echo "*               Resource Summary                 *"
echo "**************************************************"
if [ "$use_customer_s3" = "true" ]; then
cat <<EOF | column -t -s, 
Resource,Instance ID,Instance endpoint
========,===========,=================
RDS,$DBID,$rds_hostname
Redshift,$CLUSTERID,$redshift_hostname
EOF
else
cat <<EOF | column -t -s, 
Resource,Instance ID,Instance endpoint
========,===========,=================
RDS,$DBID,$rds_hostname
Redshift,$CLUSTERID,$redshift_hostname
S3,$s3_staging_bucket,$s3_staging_path
EOF
fi
echo ""
echo "You can copy and paste the following line to add the sample definition to your pipeline once it is created (Step 2)"
if [ "$use_customer_s3" = "true" ]; then
echo "> aws datapipeline put-pipeline-definition --pipeline-id <pipeline_id> --pipeline-definition file://`pwd`/sqoop.json --parameter-values myRdsEndpoint=\"$rds_hostname\" myRedshiftEndpoint=\"$redshift_hostname\" myS3StagingPath=\"<S3_staging_path>\""
else
echo "> aws datapipeline put-pipeline-definition --pipeline-id <pipeline_id> --pipeline-definition file://`pwd`/sqoop.json --parameter-values myRdsEndpoint=\"$rds_hostname\" myRedshiftEndpoint=\"$redshift_hostname\" myS3StagingPath=\"$s3_staging_path\""
fi
echo ""
echo "If you wish to delete all the resources created for this sample, please run the teardown script as follows"
if [ "$use_customer_s3" = "true" ]; then
    echo "> ./teardown.sh $DBID $CLUSTERID"
else
    echo "> ./teardown.sh $DBID $CLUSTERID $s3_staging_path"
fi
