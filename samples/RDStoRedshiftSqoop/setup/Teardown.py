from RdsToRedshiftSqoopSample import RDStoRedshiftSqoopSample
from Utilities import check_working_directory

import argparse


if __name__ == '__main__':
    check_working_directory()

    parser = argparse.ArgumentParser(description='Teardown for RDS to Redshift Sqoop pipeline sample')
    parser.add_argument('--s3-path', action="store", dest="s3_bucket_path")
    parser.add_argument('--rds-instance-id', action="store", dest="rds_instance_id")
    parser.add_argument('--redshift-cluster-id', action="store", dest="redshift_cluster_id")
    args = parser.parse_args()

    sample = RDStoRedshiftSqoopSample()

    if args.rds_instance_id is not None:
        sample.destroy_rds(args.rds_instance_id)

    if args.redshift_cluster_id is not None:
        sample.destroy_redshift(args.redshift_cluster_id)

    if args.s3_bucket_path is not None:
        sample.destroy_s3_bucket(args.s3_bucket_path)
