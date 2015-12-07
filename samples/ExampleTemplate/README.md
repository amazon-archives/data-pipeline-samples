# {{Example Name}}

{{Description of activites performed in the example}}

## Parameters

<table>

<tr><th>Parameter</th><th>Required</th><th>Description</th></tr>

<tr>
<td>{{Parameter Name}}</td>
<td>{{yes/no}}</td>
<td>
{{Description}} {{Example or Default}}
</td>
</tr>

</table>

## Setup (Optional)

You can use the setup script in the sample directory to create {{resources}} to use in this example.
You can skip this step if you have {{resources}} that you want to use. The script will take a minute
to complete, and when it's finished it will print the resource identifier of the
{{resources}} that it created.

```sh
 $> python setup.py
```

If the script fails with an ImportError, you may need to [setup your virtualenv](https://github.com/awslabs/data-pipeline-samples#setup).

## Running this sample

Create a new pipeline. Throughout this section we assume that the {{Example Directory}} sample directory is
your current working directory.

```sh
 $> aws datapipeline create-pipeline --name {{example_name}} --unique-id {{example_name}} 
# {
#     "pipelineId": "df-03971252U4AVY60545T7"
# }
```

Upload the [pipeline definition](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-writing-pipeline-definition.html). Use the `pipelineId` that was returned by the `create-pipeline`
command. Specify the name of an S3 bucket where the output from pipline activites will be stored.
This will either be the bucket name that was printed by the setup script or another bucket that
you've created. You can also specify any optional parameters for this example here.


```sh
  $> aws datapipeline put-pipeline-definition --pipeline-id <your pipelineId> --pipeline-definition file://TeraSortHadoopBenchmark.json {{--parameter-values values}}
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
from this command will show FINISHED for all pipeine nodes.

```sh

  >$ aws datapipeline list-runs --pipeline-id <your pipelineId>
# {{example output}}

```

{{what happens when the pipeline is finished}}

## Next steps

{{things to try next}}

Once the pipeline is completed, you can delete it with the following command. If you try to run the
sample again without deleting, you may receive errors or unexpected behavior.

```sh
 $> aws datapipeline delete-pipeline --pipeline-id <your pipelineId>
```

The resources used by this example will incur normal charges. If you provisioned resources using the
setup script, you can free them by running the following command in the sample directory.

```sh
 $> python setup.py --teardown
```

## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not
be sufficient for production environments. Users should carefully inspect samples before running
them.

*Use at your own risk.*

Copyright 2011-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved. Licensed under the
[Amazon Software License](http://aws.amazon.com/asl/).

