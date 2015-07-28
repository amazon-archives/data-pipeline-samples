# Diagnosis Tool
The diagnosis tool can be used to do a quick check to test whether your connectivity is fine. It checks for the following:
 - Connectivity to different regions
 - Connections to S3, DynamoDB, Redshift and RDS.

## Instructions
It can be done in two different ways:
1. Using the terminal

2. Using the AWS Data Pipeline Console


###Using the terminal
1. Download the diagnostics jar file: https://s3.amazonaws.com/data-pipeline-samples/diagnose-sample/Diagnose.jar

2. Run the following command (The config option takes in the path and file name of your credentials.json file)
`$> java -jar <path_to_jar>/Diagnose.jar --config <path_to_file>/credentials.json

NOTE: If you are running it from an AWS CLI that has been configured with your credentials, you can run just the following command:
	`$> java -jar <path_to_jar>/Diagnose.jar`


###Using the AWS Data Pipeline Console
1. Download the pipeline definition json file:https://s3.amazonaws.com/data-pipeline-samples/diagnose-sample/diagnose_pipeline.json.

3. Use the AWS Data Pipeline console to create a new pipeline and import the definition from the downloaded json file.

4. Activate the pipeline and wait for it to finish.

5. Once it's finished, open the stdout logs and ensure that all the connectivity checks have been completed successfully.


