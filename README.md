THIS IS A WORK IN PROGRESS
=====================

![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/setup/logo/datapipelinelogo.jpeg)

Data Pipeline Samples
=====================
AWS Data Pipeline is a web service that you can use to automate the movement and transformation of data. With AWS Data Pipeline, you can define data-driven workflows, so that tasks can be dependent on the successful completion of previous tasks. You define the parameters of your data transformations and AWS Data Pipeline enforces the logic that you've set up.




# Running the samples

##Get the samples

```sh
 $> git clone https://github.com/awslabs/data-pipeline-samples.git
```

##Install the AWS CLI 
Follow the instructions [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html) to install the AWS CLI

##Create default IAM Roles

Use the setup_roles.sh command to get your default roles setup.

```sh
 $> chmod 755 setup/setup_roles.sh
 $> setup/setup_roles.sh
```

##Run one of the samples

```sh
 $> aws datapipeline create-pipeline --name hello_world_pipeline --unique-id hello_world_pipeline 

# You receive a pipeline activity like this. 
  -----------------------------------------
  |             CreatePipeline             |
  +-------------+--------------------------+
  |  pipelineId |  df-0554887H4KXKTY59MRJ  |
  +-------------+--------------------------+

#now upload the pipeline definition 

  $> aws datapipeline put-pipeline-definition --pipeline-id df-0554887H4KXKTY59MRJ --pipeline-definition file://samples/helloworld/helloworld.json --parameter-values myS3LogsPath="<your s3 logging path>"

# You receive a validation messages like this

  ----------------------- 
  |PutPipelineDefinition|
  +-----------+---------+
  |  errored  |  False  |
  +-----------+---------+

#now activate the pipeline
  $> aws datapipeline activate-pipeline --pipeline-id df-0554887H4KXKTY59MRJ


#check the status of your pipeline 

  >$ aws datapipeline list-runs --pipeline-id df-0554887H4KXKTY59MRJ
         Name                                                Scheduled Start      Status
         ID                                                  Started              Ended
  ---------------------------------------------------------------------------------------------------
     1.  A_Fresh_NewEC2Instance                              2015-07-19T22:48:30  RUNNING
         @A_Fresh_NewEC2Instance_2015-07-19T22:48:30         2015-07-19T22:48:35
  
     2.  ShellCommandActivity_HelloWorld                     2015-07-19T22:48:30  WAITING_FOR_RUNNER
         @ShellCommandActivity_HelloWorld_2015-07-19T22:48:  2015-07-19T22:48:34



```


##Disclaimer
The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

_Use at your own risk._

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You
may not use this file except in compliance with the License. A copy of
the License is located at

http://aws.amazon.com/asl/

