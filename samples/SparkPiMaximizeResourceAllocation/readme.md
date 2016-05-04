#EMRActivity SparkPi example with maximizeResourceAllocation

##About the sample
This Pipeline definition launches an EmrCluster (emr-4.x.x) with [maximizeResourceAllocation](http://docs.aws.amazon.com/ElasticMapReduce/latest/ReleaseGuide/emr-spark-configure.html#d0e17386) with simple [SparkPi](https://github.com/apache/spark/blob/master/examples/src/main/scala/org/apache/spark/examples/SparkPi.scala) example in yarn-client mode. Also, it runs on [ONDEMAND](https://aws.amazon.com/about-aws/whats-new/2016/02/now-run-your-aws-data-pipeline-on-demand/) schedule. 

##Running this sample
The pipeline requires one input point from the customer:
1. The log folder for the pipeline.

##Result
You can view the output (stdout) under 'Emr Step Logs' under EmrActivity.
Pi is roughly 3.141716