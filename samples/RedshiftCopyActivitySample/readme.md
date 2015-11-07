#RedshiftCopyActivity Sample - https://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-object-redshiftcopyactivity.html

##Running this sample

```sh
 $> aws datapipeline create-pipeline --name redshift_copy_from_dynamodb_pipeline --unique-id redshift_copy_from_dynamodb_pipeline 

# You receive a pipeline activity like this. 
#   -----------------------------------------
#   |             CreatePipeline             |
#   +-------------+--------------------------+
#   |  pipelineId |  df-0554887H4KXKTY59MRJ  |
#   +-------------+--------------------------+

#now upload the pipeline definition 

  $> aws datapipeline put-pipeline-definition --pipeline-id df-0554887H4KXKTY59MRJ --pipeline-definition file://samples/RedshiftCopyActivitySample/RedshiftCopyActivitySample.json --parameter-values myConnectionString=<connection_string> myRedshiftDatabase=<database> myRedshiftUsername=<username> myRedshiftPassword=<password> myScript="copy <table_name> from 'dynamodb://<table_name>' credentials 'aws_access_key_id=<your_access_key>;aws_secret_access_key=<your_secret_key>' readratio <ratio>;" myLogUri="<your_log_dir>"

# You receive a validation messages like this

#   ----------------------- 
#   |PutPipelineDefinition|
#   +-----------+---------+
#   |  errored  |  False  |
#   +-----------+---------+

#now activate the pipeline
  $> aws datapipeline activate-pipeline --pipeline-id df-0554887H4KXKTY59MRJ


#check the status of your pipeline 

  >$ aws datapipeline list-runs --pipeline-id df-0554887H4KXKTY59MRJ
#       Name                                                Scheduled Start      Status                 
#       ID                                                  Started              Ended              
#---------------------------------------------------------------------------------------------------
#   1.  ActivityId_vmVn4                                    2015-11-06T23:52:04  WAITING_FOR_RUNNER     
#       @ActivityId_vmVn4_2015-11-06T23:52:04               2015-11-06T23:52:11                     
#
#   2.  ResourceId_idL0Y                                    2015-11-06T23:52:04  CREATING               
#       @ResourceId_idL0Y_2015-11-06T23:52:04               2015-11-06T23:52:11      
```
