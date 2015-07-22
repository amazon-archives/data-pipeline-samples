DBID=$1
CLUSTERID=$2

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
