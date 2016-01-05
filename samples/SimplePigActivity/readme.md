# Simple PigActivity

This sample demonstrates how to use a [PigActivity](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-object-pigactivity.html) to process a text input file transforming it from a ten-column dataset to an eight-column dataset.  The output, along with
the acitivity log, is saved to an [S3](https://aws.amazon.com/s3/) bucket.  The sample pipeline definition also shows how to use a script with script variables.

## Parameters

<table>
<tr><th>Parameter</th><th>Description</th></tr>
<tr>
<td>myLogUri</td>
<td>
(Required) An S3 path where the activity log will be stored. Example: "s3://data-pipeline-samples-12345"
</td>
</tr>
<tr>
<td>myPigScriptUri</td>
<td>
(Required) Use the following value for this sample - s3://data-pipeline-samples/SimplePigActivity/samplePigScript.pig</td>
</tr>
<tr>
<td>myGeneratedScriptsPath</td>
<td>
(Required) An S3 path where debugging information for the Pig script will be logged.
</td>
</tr>
<tr>
<td>myS3Input</td>
<td>
(Required) An S3 directory path that contains one or more inputs to the script.  For this sample, you can use "s3://data-pipeline-samples/SimplePigActivity/input/".
</td>
</tr>
<tr>
<td>myS3Output</td>
<td>
(Required) An S3 directory path where the output of the pig script will be sent to.  Please ensure you have permission to write to this directory.
</td>
</tr>
</table>

## Setup (Optional)

You can use the setup script in the HelloWorld sample directory to create an S3 bucket to use in
this example. You can skip this step if you have another S3 bucket that you want to use. The script
will take a minute to complete, and when it's finished it will print the resource identifier of the
S3 bucket that it created.

```sh
 $> python setup.py
# Creating resources for stack [dpl-samples-simple-pig-activity]...
#   AWS::S3::Bucket: dpl-samples-simple-pig-activity-s3bucket-2bbt69s1j29c
```

## Running this sample

Create a new pipeline. Throughout this section we assume that the HelloWorld sample directory is
your current working directory.

```sh
 $> aws datapipeline create-pipeline --name simple_pig_activity_pipeline --unique-id simple_pig_activity_pipeline_0001 
# {
#     "pipelineId": "df-074257336JDKJ6QWQCT4"
# }
```

Upload the pipeline definition. Use the `pipelineId` that was returned by the `create-pipeline`
command. Specify the name of an S3 bucket where the output and activity log will be stored. This
will either be the bucket name that was printed by the setup script or another bucket that you've
created.


```sh
  $> aws datapipeline put-pipeline-definition --pipeline-id <your pipelineId> --pipeline-definition file://pig_activity_sample.json --parameter-values myLogUri=<your log uri> myPigScriptUri=s3://data-pipeline-samples/SimplePigActivity/samplePigScript.pig myGeneratedScriptsPath=<your generated scripts path> myS3Input=s3://data-pipeline-samples/SimplePigActivity/input/ myS3Output=<your output path>
# {
#     "validationErrors": [],
#     "validationWarnings": [],
#     "errored": false
# }
```

Activate the pipeline. Use the `pipelineId` that was returned by the `create-pipeline` command.

```sh
  $> aws datapipeline activate-pipeline --pipeline-id <your pipelineId>
```

Optionally, check the status of your running pipeline. Use the `pipelineId` that was returned by the
`create-pipeline` command. When the pipeline has completed, the Status Ended column in the output
from this command will show FINISHED for all pipeine nodes. Note that it may take a minute after the
`activate-pipeline` command has completed before the `list-runs` command shows any output.

```sh

  >$ aws datapipeline list-runs --pipeline-id <your pipelineId>
#       Name                                                Scheduled Start      Status
#       ID                                                  Started              Ended
#---------------------------------------------------------------------------------------------------
#   1.  PigActivity1                                        2015-12-31T06:10:00  WAITING_FOR_RUNNER
#       @PigActivity1_2015-12-31T06:10:00                   2015-12-31T06:10:05
#
#   2.  EmrCluster1                                         2015-12-31T06:10:00  CREATING
#       @EmrCluster1_2015-12-31T06:10:00                    2015-12-31T06:10:07
#
#   3.  InputDataNode1                                      2015-12-31T06:10:00  FINISHED
#       @InputDataNode1_2015-12-31T06:10:00                 2015-12-31T06:10:05  2015-12-31T06:10:05
#
#   4.  OutputDataNode1                                     2015-12-31T06:10:00  WAITING_ON_DEPENDENCIES
#       @OutputDataNode1_2015-12-31T06:10:00                2015-12-31T06:10:05

  >$ aws datapipeline list-runs --pipeline-id <your pipelineId>
#       Name                                                Scheduled Start      Status
#       ID                                                  Started              Ended
#---------------------------------------------------------------------------------------------------
#   1.  PigActivity1                                        2015-12-31T06:10:00  FINISHED
#       @PigActivity1_2015-12-31T06:10:00                   2015-12-31T06:10:05  2015-12-31T06:21:26
#
#   2.  EmrCluster1                                         2015-12-31T06:10:00  FINISHED
#       @EmrCluster1_2015-12-31T06:10:00                    2015-12-31T06:10:07  2015-12-31T06:23:30
#
#   3.  InputDataNode1                                      2015-12-31T06:10:00  FINISHED
#       @InputDataNode1_2015-12-31T06:10:00                 2015-12-31T06:10:05  2015-12-31T06:10:05
#
#   4.  OutputDataNode1                                     2015-12-31T06:10:00  FINISHED
#       @OutputDataNode1_2015-12-31T06:10:00                2015-12-31T06:10:05  2015-12-31T06:21:28
 
```

After the pipeline is completed, the output and activity log from the pipeline will be saved to the S3 bucket that you
specified under the following prefix. To view or download these files, navigate to this prefix in
the S3 section of the [AWS Management Console](https://aws.amazon.com/console/).

    s3://<your S3 logging path>/<your pipelineId>/<pipeline instance>/<pipeline attempt>

## Next steps

Once the pipeline is completed, you can delete it with the following command. If you try to run the
sample again without deleting, you may receive errors or unexpected behavior.

```sh
 $> aws datapipeline delete-pipeline --pipeline-id <your pipelineId>
```

The resources used by this example will incur normal charges. If you provisioned resources using the
setup script, you can free them by running the following command in the HelloWorld sample directory.

```sh
 $> python setup.py --teardown
# Request to delete stack [dpl-samples-simple-pig-activity] has been sent
```


## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not
be sufficient for production environments. Users should carefully inspect samples before running
them.

*Use at your own risk.*

Copyright 2011-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved. Licensed under the
[Amazon Software License](http://aws.amazon.com/asl/).

