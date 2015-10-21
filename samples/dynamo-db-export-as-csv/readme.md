This pipeline demonstrates how to export data in dynamoDB as csv data in S3.   

Steps to run the pipeline using the cli.

1) aws datapipeline create-pipeline --name ddb-backup --unique-id some-unique-id
  => Returns a pipeline-id 

2) aws datapipeline put-pipeline-definition --pipeline-id <pipeline-id> --pipeline-definition file:///home/user/ddb-to-csv.json  

3) aws datapipeline activate-pipeline --pipeline-id <pipeline-id>
