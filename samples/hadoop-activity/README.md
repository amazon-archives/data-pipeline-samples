#Hadoop Activity word count example with Fair Scheduler queues

##About the sample
This pipeline definition when imported would run a word count splitter program (s3://elasticmapreduce/samples/wordcount/wordSplitter.py) on the public data set s3://elasticmapreduce/samples/wordcount/input/. There are two Hadoop Activities in the definition each of which run the splitter program and output to two s3 different folders with the format &lt;s3Prefix&gt;/scheduledStartTime/queue_(1|2). Each of the activities run a hadoop job on using Hadoop Fair Scheduler which is configured with two queues.

##Running this sample
The pipeline requires three input points from the customer:

1. The s3 prefix folder where the output of the word splitter would be stored. 
2. The queue configuration for Fair Scheduler sample allocations file could be found here s3://data-pipeline-samples/hadoop-activity/allocations.xml. More details http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/FairScheduler.html
3. The log folder for the pipeline.
