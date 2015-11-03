#Load Tab Separated Files in S3 to Redshift 

##About the sample
This pipeline definition when imported would instruct Redshift to load TSV files under the specified S3 Path into a specified Redshift Table. Table insert mode is OVERWRITE_EXISTING.

##Running this sample
The pipeline requires the following user input point:

1. The S3 folder where the input TSV files are located. 
2. Redshift connection info along with the target table name.
3. Redshift Cluster security group id(s).
