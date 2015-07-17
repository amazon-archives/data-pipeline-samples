![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/samples/logo/datapipelinelogo.jpeg)

Data Pipeline Samples
=====================
AWS Data Pipeline is a web service that you can use to automate the movement and transformation of data. With AWS Data Pipeline, you can define data-driven workflows, so that tasks can be dependent on the successful completion of previous tasks. You define the parameters of your data transformations and AWS Data Pipeline enforces the logic that you've set up.




# Running the samples

##Install the AWS CLI 
Follow the instructions [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html) to install the AWS CLI

##Create default IAM Roles
Create the following files defining the trusted entities for the 2 roles.

AWSDataPipeline_DefaultAssumeRole.json
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "datapipeline.amazonaws.com",
          "elasticmapreduce.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

EC2_DefaultAssumeRole.json
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

From your CLI run the following command to create the the default IAM roles for use in Pipeline Definitions. 

```sh
aws iam create-role --role-name DataPipelineDefaultRole --assume-role-policy-document file://AWSDataPipeline_DefaultAssumeRole.json
aws iam attach-role-policy --role-name DataPipelineDefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSDataPipelineRole

aws iam create-role --role-name DataPipelineDefaultResourceRole --assume-role-policy-document file://EC2_DefaultAssumeRole.json
aws iam attach-role-policy --role-name DataPipelineDefaultResourceRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforDataPipelineRole
aws iam create-instance-profile --instance-profile-name DataPipelineDefaultResourceRole
aws iam add-role-to-instance-profile --instance-profile DataPipelineDefaultResourceRole --role-name DataPipelineDefaultResourceRole
```

##Get the samples

```sh
 $> git clone https://github.com/awslabs/data-pipeline-samples.git
```


##Disclaimer
The samples in this repository are meant to help users get started with Data Pipeline. They may not be sufficient for production environments. Users should carefully inspect code samples before running them.

_Use at your own risk._

Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Amazon Software License (the "License"). You
may not use this file except in compliance with the License. A copy of
the License is located at

http://aws.amazon.com/asl/

