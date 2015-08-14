#XML to DynamoDB Import

##Running the sample pipeline
The json format could be directly used and either imported in the Console -> Create Pipeline or used in the aws cli.<br/>
The Pipeline definition would copy an example xml from s3://data-pipeline-samples/dynamodbxml/input/serde.xml to local to be imported into the table.<br/>
The hive script is configured for running on a DynamoDB table with keys as "customer_id, financial, income, demographics".<br/>
The hive script would then insert the xml data into the table based on parsing which is using hive-xml-serde. The parsing is similar to xpath parsing of a xml file.<br/>
The resultant should be the data is available in the DynamoDB table. <br/>


