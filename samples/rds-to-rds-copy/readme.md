This pipeline demonstrates how to copy data from S3 to RDS instances and between RDS instances using  datapipeline.  Following is the data flow

S3 -> Mysql -> Oracle -> PostGres -> SqlServer -> S3 

Steps to run the pipeline using the cli.

1) aws datapipeline create-pipeline --name ddb-backup --unique-id some-unique-id
  => Returns a pipeline-id 

2) aws datapipeline put-pipeline-definition --pipeline-id <pipeline-id> --pipeline-definition file:///home/user/rds-to-rds-copy.json  

3) aws datapipeline activate-pipeline --pipeline-id <pipeline-id>
