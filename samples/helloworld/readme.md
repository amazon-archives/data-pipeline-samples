#Hello World

##Running this sample

```sh
 $> aws datapipeline create-pipeline --name hello_world_pipeline --unique-id hello_world_pipeline 

# You receive a pipeline activity like this. 
#   -----------------------------------------
#   |             CreatePipeline             |
#   +-------------+--------------------------+
#   |  pipelineId |  df-0554887H4KXKTY59MRJ  |
#   +-------------+--------------------------+

#now upload the pipeline definition 

  $> aws datapipeline put-pipeline-definition --pipeline-id df-0554887H4KXKTY59MRJ --pipeline-definition file://samples/helloworld/helloworld.json --parameter-values myS3LogsPath="<your s3 logging path>"

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
#          Name                                                Scheduled Start      Status
#          ID                                                  Started              Ended
#   ---------------------------------------------------------------------------------------------------
#      1.  A_Fresh_NewEC2Instance                              2015-07-19T22:48:30  RUNNING
#          @A_Fresh_NewEC2Instance_2015-07-19T22:48:30         2015-07-19T22:48:35
#   
#      2.  ShellCommandActivity_HelloWorld                     2015-07-19T22:48:30  WAITING_FOR_RUNNER
#          @ShellCommandActivity_HelloWorld_2015-07-19T22:48:  2015-07-19T22:48:34

```
