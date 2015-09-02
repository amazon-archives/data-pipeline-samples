![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/setup/logo/datapipelinelogo.jpeg)

Load Detailed AWS Billing logs into a Redshift table
=====================

The Load AWS Detailed Billing Report Into Redshift template loads the AWS detailed billing report for the current month stored in an Amazon S3 folder to a Redshift table. If you would like to process files from previous months please pick a schedule that starts in the past, so the scheduled start time can be the timestamp of the CSVs for the period of interest. The input file must be of the .csv.zip format. Existing entries in the Redshift table are updated with data from Amazon S3 and new entries from Amazon S3 data are added to the Redshift table. If the table does not exist, it will be automatically created with the same schema as the AWS detailed billing report. The input report file is unzipped and converted to a GZIP file which is stored in the Amazon S3 staging folder before loading to Redshift.

## Billing logs format

This sample specifically targets detailed billing reports for customers who have opted into consolidated billing and have other linked accounts. Their billing logs should have the following fields:

```invoice_id
payer_account_id
linked_account_id
record_type
product_name
rate_id
subscription_id
pricing_plan_id
usage_type
operation
availability_zone
reserved_instance
item_description
usage_start_date
usage_end_date
usage_quantity
blended_rate
blended_cost
unblended_rate
unblended_cost
```

## How it works

The pipeline will download the billing logs .gzips from the S3 bucket matching the pipeline's scheduled start time into a newly created EC2 instance. A shell script will then uncompress these into a staging bucket in S3. The RedshiftCopyActivity then creates a table in Redshift with columns as listed above and then loads in the staged CSV files. A final cleanup script deletes the temporary staged files in S3.

## Different billing formats

Logs for accounts without consolidated billing or linked accounts will replace 4 fields [blended_rate, blended_cost, unblended_rate, unblended_cost] with 2 fields [rate, cost]. To load these logs into Redshift you must modify the schema of the Redshift table to look similar to the following:

```invoice_id varchar(255), payer_account_id varchar(255), linked_account_id varchar(255), record_type varchar(255), product_name varchar(255), rate_id varchar(255), subscription_id varchar(255), pricing_plan_id varchar(255), usage_type varchar(255), operation varchar(255), availability_zone varchar(255), reserved_instance varchar(255), item_description varchar(255), usage_start_date varchar(255), usage_end_date varchar(255), usage_quantity FLOAT, rate FLOAT, cost FLOAT```

## Parameters

Specifying these parameters is sufficient to get this pipeline to work:

```
"parameters": [
    {
      "id": "myS3BillingLogLoc",
      "type": "AWS::S3::ObjectKey",
      "description": "Input S3 folder for billing report",
      "helpText": "S3 folder that has the monthly AWS detailed billing report files with a .csv.zip format."
    },
    {
      "id": "myS3StagingLoc",
      "type": "AWS::S3::ObjectKey",
      "description": "S3 staging folder",
      "helpText": "Folder to store the unzipped CSV file before loading to Redshift. The S3 folder must be in the same region as the Redshift cluster."
    },
    {
      "id": "myRedshiftJdbcConnectStr",
      "type": "String",
      "description": "Redshift JDBC connection string",
      "watermark": "jdbc:postgresql://endpoint:port/database?tcpKeepAlive=true"
    },
    {
      "id": "myRedshiftUsername",
      "type": "String",
      "description": "Redshift username"
    },
    {
      "id": "*myRedshiftPassword",
      "type": "String",
      "description": "Redshift password"
    },
    {
      "id": "myRedshiftSecurityGrps",
      "type": "String",
      "isArray": "true",
      "description": "Redshift security group(s)",
      "default":"default",
      "helpText": "The names of one or more security groups that are assigned to the Redshift cluster.",
      "watermark": "security group name"
    },
    {
      "id": "myRedshiftDbName",
      "type": "String",
      "description": "Redshift database name"
    },
    {
      "id": "myRedshiftTableName",
      "type": "String",
      "description": "Redshift table name",
      "helpText": "The name of an existing table or a new table that will be created with the same schema as the AWS detailed billing report."
    }
  ]
```
