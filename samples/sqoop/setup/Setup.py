from SqoopSample import SqoopSample
import sys

if __name__ == '__main__':
    sqoop_sample = SqoopSample()

    s3_bucket_path = sqoop_sample.check_for_s3_path_argument(sys.argv)
    if s3_bucket_path == "":
        sqoop_sample.create_s3_bucket()
    elif sqoop_sample.validate_s3_bucket_path(s3_bucket_path) == False:
        sys.exit(0) 

    sqoop_sample.create_rds_instance()
    sqoop_sample.create_redshift_cluster()
    sqoop_sample.run_setup_datapipeline()
    sqoop_sample.print_setup_results()
