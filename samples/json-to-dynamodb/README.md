# json-to-dynamodb  
Example that loads a json stored in an S3 location into a DynamoDB table

The pipeline definition reads a customer json file stored in an S3 location and loads the data to a DynamoDB table called customers.

The load to DynamoDb is done via a hive script [json_to_ddb.q](json_to_ddb.q)  that reads the json from the S3 location into an external table and then leverages the `org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler` to move the data from the Hive external table to a DynamoDb table called 'customers'.



## Disclaimer

The samples in this repository are meant to help users get started with Data Pipeline. They may not
be sufficient for production environments. Users should carefully inspect samples before running
them.

*Use at your own risk.*

Licensed under the MIT-0 License.
