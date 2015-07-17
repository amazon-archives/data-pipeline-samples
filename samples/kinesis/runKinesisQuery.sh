aws s3 cp s3://vinayakt-scripts/checkpointQuery.q .
aws s3 cp s3://vinayakt-scripts/createTableFromKinesisStream.q .

ITERATION_COUNT=0;
if [ -a /mnt/taskRunner/iterationCount ]; then
   ITERATION_COUNT=`cat /mnt/taskRunner/iterationCount;`
fi

if [ "$ITERATION_COUNT" -eq "$ITERATION_COUNT" ]; then
   echo "Iteration count is $ITERATION_COUNT"
else
   ITERATION_COUNT=0;
   echo "Set iteration count to 0"
fi

hive -f createTableFromKinesisStream.q
hive -hivevar iterationNo=$ITERATION_COUNT -f checkpointQuery.q

echo `expr $ITERATION_COUNT + 1` > /mnt/taskRunner/iterationCount
