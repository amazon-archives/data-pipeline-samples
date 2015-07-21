DROP TABLE apachelog;

CREATE TABLE apachelog (
  host STRING,
  IDENTITY STRING,
  USER STRING,
  TIME STRING,
  request STRING,
  STATUS STRING,
  SIZE STRING,
  referrer STRING,
  agent STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") ([0-9]*) ([0-9]*) ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\")"
)
STORED BY
'com.amazon.emr.kinesis.hive.KinesisStorageHandler'
TBLPROPERTIES("kinesis.stream.name"="AccessLogStream");

CREATE TABLE IF NOT EXISTS apachelog_s3 (
  host STRING,
  IDENTITY STRING,
  USER STRING,
  TIME STRING,
  request STRING,
  STATUS STRING,
  SIZE STRING,
  referrer STRING,
  agent STRING
)
PARTITIONED BY(iteration_no int)
LOCATION '${s3Location}';
