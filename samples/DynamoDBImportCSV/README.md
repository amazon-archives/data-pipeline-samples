#DynamoDB to CSV import

##About the sample
The pipeline definition is used to import DynamoDB data to a CSV format.

##Running the pipeline 

Example DynamoDB table with keys: id

User needs to provide:

1. Input S3 folder: The s3 folder prefix from which the CSV data is to be imported.
2. DynamoDB read throughput ratio: The throughput to be used for the import operation.
3. DynamoDB table name: The table name from which we need to import the data.
4. S3 Column Mappings: A comma seperated column definitions. For example, customer_id string, income string, demographics string, financial string
4. Dynamodb Column Mappings: A comma seperated column definitions. For example, customer_id string, income string, demographics string, financial string
5. S3 to DynamoDB Column Mapping: A comma separated mapping of S3 to DynamoDB for e.g. customer_id:customer_id,income:income,demographics:demographics,financial:financial. Please take care of not using spaces in between the commas.
6. Log Uri: S3 log path to capture the pipeline logs.
