This pipeline exports data from a Dynamo DB Table to a S3 location using an EMR Cluster.

Steps to run the pipeline using the cli.

1) aws datapipeline create-pipeline --name ddb-backup --unique-id some-unique-id
  => Returns a pipeline-id 

2) aws datapipeline put-pipeline-definition --pipeline-id <pipeline-id> --pipeline-definition file:///home/user/DynamoDB-export.json --parameter-values-uri file:///home/user/example-parameters.json 

3) aws datapipeline activate-pipeline --pipeline-id <pipeline-id>
