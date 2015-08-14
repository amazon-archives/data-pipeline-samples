# Oracle-Backup

This sample pipeline does a daily backup of an Oracle database to S3 in CSV format, under an S3 prefix using the date of the backup.

It features usage of parameters and expressions for easy pipeline definition re-use, construction of a JDBC connection string for the [`JdbcDatabase`](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-object-jdbcdatabase.html) object, and to store backups on AWS under the date the pipeline was started (instead of the full timestamp).

## Instructions

1. The Oracle JDBC driver is not available by default on instances launched using Data Pipeline. In order to use it, you will need to [download the driver](http://www.oracle.com/technetwork/database/features/jdbc/index-091264.html) from Oracle.

2. Upload the driver JAR to an S3 bucket.

3. Install the [AWS CLI](http://aws.amazon.com/cli/). This is available by default on Amazon Linux instances.

4. Configure the credentials with `aws configure`. If using role credentials, then you can skip all fields except for the default region.

5. Fill out `values.json` with the appropriate values; there are descriptions of the parameters in `parameters.json` as well as below.

6. Create a pipeline either with the AWS Console, or through the CLI. Through the CLI, this can be done with

    `aws datapipeline create-pipeline --name <name> --unique-id <unique-identifier>`

7.  Using the pipeline-id (`df-XXXXXX`), submit the pipeline definition with parameters and values.

    `aws datapipeline put-pipeline-definition --pipeline-id <pipeline-id> --pipeline-definition file://definition.json --parameter-objects file://parameters.json --parameter-values-uri file://values.json`

8. Activate the pipeline
    `aws datapipeline activate-pipeline --pipeline-id <pipeline-id>`


##Parameters

myBackupLocation: S3 backup location (i.e. `s3://mybucket/backups/oracle`)

myOracleDriverLocation: S3 location to fetch Oracle JDBC driver from (i.e. `s3://mybucket/ojdbc6.jar`)

myOracleHost: Oracle host address (i.e. `abc.xyz.us-east-1.rds.amazonaws.com`)

myOraclePort: Oracle port (i.e. `1521`)

myOracleDatabase: Oracle SID/database (.i.e. `ORCL`)

myOracleUser: Oracle user

myOraclePassword: Password to use

myOracleTable: Name of the Oracle table to back up

myTerminateAfter: Terminate instance after a certain amount of time (i.e. `2 Hours`)

myPipelineLogUri: Log pipeline execution details to an S3 location (i.e. `s3://mybucket/pipelinelogs`)
