#XML to DynamoDB Import

##Running the sample pipeline
The json format could be either directly imported in the Console -> Create Pipeline or used in the aws datapipeline cli.<br/>
The Pipeline definition would copy an example xml from s3://data-pipeline-samples/dynamodbxml/input/serde.xml to local. This step is required for creating a temporary xml table using hive. The hive script is configured for running on a DynamoDB table with keys as "customer_id, financial, income, demographics". It finally performs an import from the temporary xml table to dynamodb<br/>
The data from the xml file is parsed using hive xml serde. The parsing functionality is similar to parsing in xpath<br/>
The resultant should be the data is available in the DynamoDB table. <br/>


