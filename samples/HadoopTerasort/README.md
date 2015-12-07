# Hadoop TeraSort 10GB Sort Benchmark

This sample sets up a Data Pipeline based on the [Hadoop](https://hadoop.apache.org/)
[TeraSort](https://hadoop.apache.org/docs/r2.7.1/api/index.html?org/apache/hadoop/examples/terasort/package-summary.html)
example, which is included with the Hadoop distribution. The pipeline performs four actions:
generate 10GB of random data, sorts, validates the result, and saves the Hadoop configuration and
benchmark statistics to an [S3](https://aws.amazon.com/s3/) bucket.

The benchmark statistics are gnerated by a shell script stored in a public S3 bucket. A copy of that
script is included in this directory for your convenience.

## Parameters

<table>

<tr><th>Parameter</th><th>Required</th><th>Description</th></tr>
<tr>
<td>myS3Path</td>
<td>yes</td>
<td>
An <a href="http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html#object-keys">S3 key</a> where the Hadoop configuration and benchmark results will be stored. Example: "s3://data-pipeline-samples-12345"
</td>
</tr>

<tr>
<td>myEmrReleaseLabel</td>
<td>no</td>
<td>
The release label for the Amazon <a
href="http://docs.aws.amazon.com/ElasticMapReduce/latest/ReleaseGuide/emr-release-components.html">EMR
release</a>. This is used to provision the <a
href="http://docs.aws.amazon.com/ElasticMapReduce/latest/ManagementGuide/emr-what-is-emr.html">EMR
cluster</a> where the Hadoop jobs will be run. Default: "emr-4.1.0"
</td>
</tr>

<tr>
<td>myJhistProcessingScriptLocation</td>
<td>no</td>
<td>The location of the shell script that will be used to process the job history files produced by the Hadoop activities. Default: "s3://datapipeline-samples/HadoopTerasort/process-jhist.sh"
</tr>

</table>

## Setup (Optional)

You can use the setup script in the HadoopTerasort sample directory to create an S3 bucket to use in
this example. You can skip this step if you have another S3 bucket that you want to use. The script
will take a minute to complete, and when it's finished it will print the resource identifier of the
S3 bucket that it created.

```sh
 $> python setup.py
```

# Running this sample

Create a new pipeline. Throughout this section we assume that the HadoopTerasort sample directory is
your current working directory.

```sh
 $> aws datapipeline create-pipeline --name hadoop_terasort_pipeline --unique-id hadoop_terasort_pipeline 
# {
#     "pipelineId": "df-03971252U4AVY60545T7"
# }
```

Upload the [pipeline definition](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-writing-pipeline-definition.html). Use the `pipelineId` that was returned by the `create-pipeline`
command. Specify the name of an S3 bucket where the output from pipline activites will be stored.
This will either be the bucket name that was printed by the setup script or another bucket that
you've created. You can also specify any optional parameters for this example here.


```sh
  $> aws datapipeline put-pipeline-definition --pipeline-id <your pipelineId> --pipeline-definition file://TeraSortHadoopBenchmark.json --parameter-values myS3Path="s3://<your s3 logging path>"
# {
#     "errored": false,
#     "validationWarnings": [],
#     "validationErrors": []
# }
```

Activate the pipeline. Use the `pipelineId` that was returned by the `create-pipeline` command.

```sh
  $> aws datapipeline activate-pipeline --pipeline-id <your pipelineId>
```

Optionally, check the status of your running pipeline. Use the `pipelineId` that was returned by the
`create-pipeline` command. When the pipeline has completed, the Status Ended column in the output
from this command will show FINISHED for all pipeline nodes.

```sh

  >$ aws datapipeline list-runs --pipeline-id <your pipelineId>
#          Name                                                Scheduled Start      Status                 
#          ID                                                  Started              Ended              
#   ---------------------------------------------------------------------------------------------------
#      1.  EmrCluster_HadoopTerasort                           2015-10-14T18:57:24  CREATING               
#          @EmrCluster_HadoopTerasort_2015-10-14T18:57:24      2015-10-14T18:57:28                     
#   
#      2.  ProcessJHIST                                        2015-10-14T18:57:24  WAITING_ON_DEPENDENCIES
#          @ProcessJHIST_2015-10-14T18:57:24                   2015-10-14T18:57:27                     
#   
#      3.  TeraGen_1GB                                         2015-10-14T18:57:24  WAITING_FOR_RUNNER     
#          @TeraGen_1GB_2015-10-14T18:57:24                    2015-10-14T18:57:27                     
#   
#      4.  TeraSort                                            2015-10-14T18:57:24  WAITING_ON_DEPENDENCIES
#          @TeraSort_2015-10-14T18:57:24                       2015-10-14T18:57:27                     
#   
#      5.  TeraValidate                                        2015-10-14T18:57:24  WAITING_ON_DEPENDENCIES
#          @TeraValidate_2015-10-14T18:57:24                   2015-10-14T18:57:28   

```

After the pipeline is completed, the output and activity log from the pipeline will be saved to the S3 bucket that you
specified. To view or download these files, navigate to this prefix in
the S3 section of the [AWS Management Console](https://aws.amazon.com/console/).

    s3://<your S3 logging path>/HadoopTerasort

## Next steps

Take a look at the pipeline definition file to see how you might update configuration options to fit
your needs. For example, you might want to change the [EMR release](http://docs.aws.amazon.com/ElasticMapReduce/latest/ReleaseGuide/emr-release-components.html) version.
This currently defaults to to emr-4.1.0 in
the definition file. In addition, we used a bootstrap action to configure memory usage. To use the
default configuration instead, remove the `bootstrapAction` field from the [EmrCluster resource
definition](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-object-emrcluster.html).

Once the pipeline is completed, you can delete it with the following command. If you try to run the
sample again without deleting, you may receive errors or unexpected behavior.

```sh
 $> aws datapipeline delete-pipeline --pipeline-id <your pipelineId>
```

The resources used by this example will incur normal charges. If you provisioned resources using the
setup script, you can free them by running the following command in the {{Example Name}} sample directory.

```sh
 $> python setup.py --teardown
# Request to delete stack [{{stack name}}] has been sent
```

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not
be sufficient for production environments. Users should carefully inspect samples before running
them.

*Use at your own risk.*

Copyright 2011-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved. Licensed under the
[Amazon Software License](http://aws.amazon.com/asl/).

