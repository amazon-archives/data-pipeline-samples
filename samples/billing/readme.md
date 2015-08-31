![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/setup/logo/datapipelinelogo.jpeg)

Load Detailed AWS Billing logs into a Redshift table
=====================

The Load AWS Detailed Billing Report Into Redshift template loads the AWS detailed billing report for the current month stored in an Amazon S3 folder to a Redshift table. If you would like to process files from previous months please pick a schedule that starts in the past, so the scheduled start time can be the timestamp of the CSVs for the period of interest. The input file must be of the .csv.zip format. Existing entries in the Redshift table are updated with data from Amazon S3 and new entries from Amazon S3 data are added to the Redshift table. If the table does not exist, it will be automatically created with the same schema as the AWS detailed billing report. The input report file is unzipped and converted to a GZIP file which is stored in the Amazon S3 staging folder before loading to Redshift.
