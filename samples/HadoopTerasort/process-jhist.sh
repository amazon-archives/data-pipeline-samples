#!/bin/bash

echo "Number of arguments: $#"
echo "Arguments: $@"
S3_Target=$1
echo "S3 Target output path: $S3_Target"

# --------------------------------------------------------------
# TeraSort Benchmark JHIST Publish Script
# This script is a reference script.
# TeraSortHadoopBenchmark pipeline uses the script hosted at: s3://datapipeline-us-east-1/sample-scripts/HadoopTeraSort/process-jhist.sh 
# --------------------------------------------------------------

# --------------------------------------------------------------
# Any code, applications, scripts, templates, proofs of concept, documentation and other items provided by AWS under this SOW are AWS Content, as defined in the Agreement, and are provided for illustration purposes only. All such AWS Content is provided solely at the option of AWS, and is subject to the terms of the Addendum and the Agreement. Customer is solely responsible for using, deploying, testing, and supporting any code and applications provided by AWS under the current SOW.
# --------------------------------------------------------------

# --------------------------------------------------------------
#  CHANGE LOG:
# --------------------------------------------------------------
#  2015-04-28 RG  v0.1 - Initial script
#  2015-04-28 RG  v0.2 - Added TeraSort & TeraValidate JHIST Processing Activities
#  2015-09-01 AR  v0.3 - Output to S3 target path
#  2015-11-19 JT  v0.4 - Update file name parsing and use mapred command
# --------------------------------------------------------------

# --------------------------------------------------------------
# Define Variables
# --------------------------------------------------------------




# --------------------------------------------------------------
# Process JHIST File
# --------------------------------------------------------------

path_to_jhist() {
    # perl incantation to extract the path from the ls command
    # via: http://stackoverflow.com/questions/21569172/how-to-list-only-file-name-in-hdfs
    hdfs dfs -ls -R / | grep $1 | perl -wlne 'print +(split " ",$_,8)[7]'
}

TeraGen=$(path_to_jhist TeraGen)
mapred job -history all $TeraGen > TeraGen-results.txt

TeraSort=$(path_to_jhist TeraSort)
mapred job -history all $TeraSort > TeraSort-results.txt

TeraValidate=$(path_to_jhist TeraValidate)
mapred job -history all ${TeraValidate} > TeraValidate-results.txt

# --------------------------------------------------------------
# Copy to S3
# --------------------------------------------------------------

gensecondline=`sed -n '2{p;q}' TeraGen-results.txt`;
genjob=${gensecondline:12}
date=$(date +"%m-%d-%y")
aws s3 cp TeraGen-results.txt $S3_Target/$date-$genjob/results/
aws s3 cp TeraSort-results.txt $S3_Target/$date-$genjob/results/
aws s3 cp TeraValidate-results.txt $S3_Target/$date-$genjob/results/
aws s3 cp /home/hadoop/conf $S3_Target/$date-$genjob/conf/ --recursive

exit 0
