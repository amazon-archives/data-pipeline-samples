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
# --------------------------------------------------------------

# --------------------------------------------------------------
# Define Variables
# --------------------------------------------------------------




# --------------------------------------------------------------
# Process JHIST File
# --------------------------------------------------------------
hdfs dfs -ls -R / | grep TeraGen > TeraGen-file-path.txt
TeraGenPath=$(cat TeraGen-file-path.txt)
TeraGen=${TeraGenPath:61}
hadoop job -history all ${TeraGen} > TeraGen-results.txt

hdfs dfs -ls -R / | grep TeraSort > TeraSort-file-path.txt
TeraSortPath=$(cat TeraSort-file-path.txt)
TeraSort=${TeraSortPath:61}
hadoop job -history all ${TeraSort} > TeraSort-results.txt

hdfs dfs -ls -R / | grep TeraValidate > TeraValidate-file-path.txt
TeraValidatePath=$(cat TeraValidate-file-path.txt)
TeraValidate=${TeraValidatePath:61}
hadoop job -history all ${TeraValidate} > TeraValidate-results.txt

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



