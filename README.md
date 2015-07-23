THIS IS A WORK IN PROGRESS
=====================

![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/setup/logo/datapipelinelogo.jpeg)

Data Pipeline Samples
=====================
AWS Data Pipeline is a web service that you can use to automate the movement and transformation of data. With AWS Data Pipeline, you can define data-driven workflows, so that tasks can be dependent on the successful completion of previous tasks. You define the parameters of your data transformations and AWS Data Pipeline enforces the logic that you've set up.


# Running the samples
##Setup
1 Get the samples by cloning this repository. 
```sh
 $> git clone https://github.com/awslabs/data-pipeline-samples.git
```

2 Install and configure the AWS CLI by follow the instructions [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html) to install the AWS CLI

3 Create AWS IAM roles to run the samples using the setup_roles.sh script.
```sh
 $> chmod 755 setup/setup_roles.sh
 $> setup/setup_roles.sh
```

##Run the hello world sample

###Step 1
Create the pipelineId by calling the *aws data pipeline create-pipeline* command. We'll use this pipelineId to host the pipeline definition document and ultimately to run and monitor the pipeline. 

```sh
 $> aws datapipeline create-pipeline --name hello_world_pipeline --unique-id hello_world_pipeline 
```

You will receive a pipelineId like this. 
```sh
#   -----------------------------------------
#   |             CreatePipeline             |
#   +-------------+--------------------------+
#   |  pipelineId |  df-0554887H4KXKTY59MRJ  |
#   +-------------+--------------------------+
```

###Step 2
Upload the helloworld.json sample pipeline definition by calling the *aws datapipeline put-pipeline-definition* command. This will upload and validate your pipeline definition. 

```sh
  $> aws datapipeline put-pipeline-definition --pipeline-id df-0554887H4KXKTY59MRJ --pipeline-definition file://samples/helloworld/helloworld.json --parameter-values myS3LogsPath="<your s3 logging path>"
```

You will receive a validation messages like this
```sh
#   ----------------------- 
#   |PutPipelineDefinition|
#   +-----------+---------+
#   |  errored  |  False  |
#   +-----------+---------+
```
###Step 3
Activate the pipeline by calling the *aws datapipeline activate-pipeline* command. This will cause the pipeline to start running on its defined schedule. 

```sh
  $> aws datapipeline activate-pipeline --pipeline-id df-0554887H4KXKTY59MRJ
```

Check the status of your pipeline 
```sh
  >$ aws datapipeline list-runs --pipeline-id df-0554887H4KXKTY59MRJ
```

You will receive status information on the pipeline.  
```sh
#          Name                                                Scheduled Start      Status
#          ID                                                  Started              Ended
#   ---------------------------------------------------------------------------------------------------
#      1.  A_Fresh_NewEC2Instance                              2015-07-19T22:48:30  RUNNING
#          @A_Fresh_NewEC2Instance_2015-07-19T22:48:30         2015-07-19T22:48:35
#   
#      2.  ShellCommandActivity_HelloWorld                     2015-07-19T22:48:30  WAITING_FOR_RUNNER
#          @ShellCommandActivity_HelloWorld_2015-07-19T22:48:  2015-07-19T22:48:34

```
##Examine the contents of the samples/helloworld/helloworld.json file to understand what's going on. 

```json
{
  "objects": [
  { 
      "myComment": "This object is used to set default configuration for objects in the pipeline",
      
      "id": "Default",
      "failureAndRerunMode":"cascade",
      "resourceRole": "DataPipelineDefaultResourceRole",
      "role": "DataPipelineDefaultRole",
      "pipelineLogUri": "#{myS3LogsPath}",
      "scheduleType": "cron",
      "schedule": {
        "ref": "DefaultSchedule"
      }
   },
   {
      "myComment": "This object is used to specify the time-based trigger for executing Activities and for provisioning Resources of the pipeline. In this case it is used by the 'Default' object so it will cascade down to all other objects in the pipeline if they do not override it. For this example, we are using it to specify that our pipeline will run immediately upon activation. Also, we are using the 'occurrences' option specify that the pipeline should only be run once. You can have multiple schedules defined in a pipeline.",

      "type": "Schedule",
      "id": "DefaultSchedule",
      "occurrences": "1",
      "period": "1 Day",
      "startAt": "FIRST_ACTIVATION_DATE_TIME"
    },


    { 
      "myComment": "This object is used to create an Amazon EC2 Instance that activities in the pipeline can run on.",

      "id": "A_Fresh_NewEC2Instance",
      "type": "Ec2Resource",
      "terminateAfter": "1 Hour"
    },
    {
     "myComment": "This object is a ShellCommandActivity. It is used to specify the command linux shell command that will be invoked. In this case it is simply running the 'echo' command, but it can be used to run any command that is accessible on the in the shell of the Resource that runs on.",

      "id": "ShellCommandActivity_HelloWorld",
      "runsOn": {
        "ref": "A_Fresh_NewEC2Instance"
      },
      "type": "ShellCommandActivity",
      "command": "echo 'Hello World!'"
    }
  ],
"parameters": [
     {
        "myComment": "This Parameter specifies the S3 logging path for the pipeline. It is used by the 'Default' object to set the 'pipelineLogUri' value. Using Parameters helps users avoid hard coding variables in pipeline definitions. Users can instead supply these parameters when calling 'aws datapipeline put-pipeline-definition' or 'aws datapipeline activate-pipeline-definition'.",

        "id" : "myS3LogsPath",
        "type" : "AWS::S3::ObjectKey",
        "description" : "S3 path for pipeline logs."
     }
   ]
}
```


Check out the other samples in this reposity to find helpful getting started templates. 

##Disclaimer
The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect samples before running them.

_Use at your own risk._

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You
may not use this file except in compliance with the License. A copy of
the License is located at

http://aws.amazon.com/asl/

