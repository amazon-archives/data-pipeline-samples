from SqoopSample import SqoopSample
import sys

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print "Please pass the following arguments to the teardown script: " \
              "<rds_instance_id> <redshift_cluster_id> " \
              "[s3://optional/path/to/s3/bucket/created/by/setup]"
        sys.exit()

    rds_id = sys.argv[1]
    redshift_id = sys.argv[2]
    s3_path = sys.argv[3] if len(sys.argv) > 3 else ""

    sqoop_sample = SqoopSample()
    #sqoop_sample.destroy_rds(rds_id)
    #sqoop_sample.destroy_redshift(redshift_id)

    if s3_path != "":
        sqoop_sample.destroy_s3_bucket(s3_path)
