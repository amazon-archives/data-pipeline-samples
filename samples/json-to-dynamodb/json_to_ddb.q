ADD JAR s3://elasticmapreduce/samples/hive-ads/libs/jsonserde.jar;

DROP TABLE IF EXISTS customer_json;

CREATE EXTERNAL TABLE customer_json (id STRING,
                                     income STRING)
ROW FORMAT SERDE 'com.amazon.elasticmapreduce.JsonSerde'
WITH SERDEPROPERTIES ('paths'='customer_id,customer_income')
LOCATION 's3://datapipeline-samples/JsonToDynamoDb/customers.json';

DROP TABLE IF EXISTS customer_hive;

CREATE EXTERNAL TABLE customer_hive (id STRING,
                                     income STRING)
STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
TBLPROPERTIES ("dynamodb.table.name" = "customers",
               "dynamodb.column.mapping" = "id:id,income:income");

INSERT OVERWRITE TABLE customer_hive SELECT * FROM customer_json;
