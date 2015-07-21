#!/bin/bash


#check if the roles exit

key="NoSuchEntity"
res=`aws iam get-role --role-name DataPipelineDefaultRole 2>&1 | grep -o $key`

if [ "$res" != "$key" ]
then
  echo 'Roles already exist. Exiting. '
  exit 1;
fi


cat >> AWSDataPipeline_DefaultAssumeRole.json <<- EOF
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
EOF


cat >> EC2_DefaultAssumeRole.json <<- EOF
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
EOF

# setup the roles 
aws iam create-role --role-name DataPipelineDefaultRole --assume-role-policy-document file://AWSDataPipeline_DefaultAssumeRole.json
aws iam attach-role-policy --role-name DataPipelineDefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSDataPipelineRole

aws iam create-role --role-name DataPipelineDefaultResourceRole --assume-role-policy-document file://EC2_DefaultAssumeRole.json
aws iam attach-role-policy --role-name DataPipelineDefaultResourceRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforDataPipelineRole
aws iam create-instance-profile --instance-profile-name DataPipelineDefaultResourceRole
aws iam add-role-to-instance-profile --instance-profile DataPipelineDefaultResourceRole --role-name DataPipelineDefaultResourceRole


rm EC2_DefaultAssumeRole.json
rm AWSDataPipeline_DefaultAssumeRole.json