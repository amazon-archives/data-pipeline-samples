set kinesis.checkpoint.enabled=true;
set kinesis.checkpoint.metastore.table.name=MyEMRKinesisTable;
set kinesis.checkpoint.metastore.hash.key.name=HashKey;
set kinesis.checkpoint.metastore.range.key.name=RangeKey;
set kinesis.checkpoint.logical.name=TestLogicalName;
set kinesis.checkpoint.iteration.no=${iterationNo};

INSERT OVERWRITE TABLE apachelog_s3 partition (iteration_no=${hiveconf:kinesis.checkpoint.iteration.no}) SELECT * FROM apachelog;
