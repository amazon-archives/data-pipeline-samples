DBID=$1
CLUSTERID=$2
s3path=
if [ ! -z $3 ]; then
   s3path=$3
   schema=`echo $s3path | grep -o -e "^s3://"`
   if [ "$schema" != "s3://" ]; then
      echo "Please provide a valid s3 path starting with s3://<bucket>/<prefix>."
      exit 1
   fi
   # Make sure we're deleting only what we created
   match=`echo $s3path | grep -o -e "staging$"`
   if [ "$match" != "staging" ]; then
      echo "$s3path was not created by setup.sh"
      exit 1
   fi
   s3bucket=`echo $s3path | sed "s/s3:\/\///g" | cut -d/ -f1`
   
   echo "removing $s3bucket"
   aws s3 rm $s3path --recursive
   aws s3api delete-bucket --bucket $s3bucket
fi

echo "destroying resources for sqoop sample"
aws rds delete-db-instance --db-instance-identifier $DBID --skip-final-snapshot
while true; do
   error=`aws rds describe-db-instances --db-instance-identifier $DBID 2>&1 | grep DBInstanceNotFound`
   if ! [ "$error" = "" ]
   then
      break;
   fi
   echo "Waiting for RDS instance $DBID to shut down."
   sleep 30
done

aws rds delete-db-security-group --db-security-group-name "aws_data_pipeline_sqoop_sample_security_group"
aws redshift delete-cluster --cluster-identifier $CLUSTERID --skip-final-cluster-snapshot
