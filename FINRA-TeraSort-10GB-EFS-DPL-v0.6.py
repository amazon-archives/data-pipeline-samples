#!/usr/bin/env python

# --------------------------------------------------------------
# FINRA TeraSort 10GB Benchmark DataPipeline Script
#
# This sample script was created to help jumpstart developers new
# to DataPipeline.  It incorporates Activities with Dependencies, Schedules,
# Resources, and Actions integrated with SNS notifications. 
# --------------------------------------------------------------

# --------------------------------------------------------------
# Any code, applications, scripts, templates, proofs of concept, documentation and other items provided by AWS under this SOW are AWS Content, as defined in the Agreement, and are provided for illustration purposes only. All such AWS Content is provided solely at the option of AWS, and is subject to the terms of the Addendum and the Agreement. Customer is solely responsible for using, deploying, testing, and supporting any code and applications provided by AWS under the current SOW.
# --------------------------------------------------------------

# --------------------------------------------------------------
#  CHANGE LOG:
# --------------------------------------------------------------
#  2015-04-28 RG  v0.1 - Initial script
#  2015-04-29 RG  v0.2 - Broke appart TeraGen, TeraSort & TeraValidate into separate Activities
#  2015-05-18 RG  v0.3 - Added Activity to process the TeraSort JHIST File & push it to an S3
#                        bucket fronted by S3 Explorer
#  2015-06-02 RG  v0.4 - Separated DataPipeline Definition out from put_pipeline_definition so
#                        it can be more easily moved to a separate file if desired 
#  2015-06-13 RG  v0.5 - Added parameterObjects and parameterValues
#  2015-06-13 RG  v0.6 - Backed off of some of the Parameters due to issues using them in Ids and Actions, added Spot for Master and Core, 
# --------------------------------------------------------------

import os, sys, time, math, datetime
from datetime import timedelta
import boto3
from boto.exception import BotoServerError

# --------------------------------------------------------------
# Define the Client
# --------------------------------------------------------------
datapipeline = boto3.client("datapipeline")

# --------------------------------------------------------------
# Define Pipeline Objects
# --------------------------------------------------------------
thePipelineObjects = [
		{
            "id": "Activity_TeraGen",
            "name": "TeraGen",
            "fields": [
                {
                	"key": "schedule",
                	"refValue": "DefaultSchedule"
                },
                {
                	"key": "runsOn",
                	"refValue": "EmrCluster"
                },
                {
                	"key": "onSuccess",
                	"refValue": "Action_TeraGen_Finished"
                },
                {
                	"key": "onFail",
                	"refValue": "Action_TeraGen_Failed"
                },
                {
                	"key": "type",
                	"stringValue": "EmrActivity"
                },
                {
                	"key": "preStepCommand",
                	"stringValue": "echo s3://#{myS3BucketLogLocation}/test-results/#{myBenchmarkTestTag}-Test-#{myBenchmarkTestId}/ > /tmp/test_logs_s3_location.txt"
#
# Attempting to add date & time to S3 prefix.
#
#                	"stringValue": "echo s3://#{myS3BucketLogLocation}/test-results/#{format(myDateTime, 'MM-dd-YYYY_hh')}-#{myBenchmarkTestTag}-Test-#{myBenchmarkTestId}/ > /tmp/test_logs_s3_location.txt"
#                	"stringValue": "echo s3://#{myS3BucketLogLocation}/test-results/#{node.@scheduledStartTime.format('MM-dd-YYYY_hh-mm')}-#{myBenchmarkTestTag}-Test-#{myBenchmarkTestId}/ > /tmp/test_logs_s3_location.txt"

                },
                {	
                	"key": "step",
                	"stringValue": 	"/home/hadoop/hadoop-examples.jar,teragen,#{myTeraGenNumber},/mnt/var/terasort/#{myDataSizeForTest}/input"
                },
            ]
    	},
        {
            "id": "Activity_TeraSort",
            "name": "TeraSort",
            "fields": [
                {
                	"key": "schedule",
                	"refValue": "DefaultSchedule"
                },
                {
                	"key": "runsOn",
                	"refValue": "EmrCluster"
                },
                {
                	"key": "onSuccess",
                	"refValue": "Action_TeraSort_Finished"
                },
                {
                	"key": "onFail",
                	"refValue": "Action_TeraSort_Failed"
                },
                {
                	"key": "type",
                	"stringValue": "EmrActivity"
                },
                {
                	"key": "dependsOn",
                	"refValue": "Activity_TeraGen"                
				},
                {	
                	"key": "step",
                	"stringValue": 	"/home/hadoop/hadoop-examples.jar,terasort,/mnt/var/terasort/#{myDataSizeForTest}/input,/mnt/var/terasort/#{myDataSizeForTest}/output/"
                },
            ]
        },
        {
            "id": "Activity_TeraValidate",
            "name": "TeraValidate",
            "fields": [
                {
                	"key": "schedule",
                	"refValue": "DefaultSchedule"
                },
                {
                	"key": "runsOn",
                	"refValue": "EmrCluster"
                },
                {
                	"key": "onSuccess",
                	"refValue": "Action_TeraValidate_Finished"
                },
                {
                	"key": "onFail",
                	"refValue": "Action_TeraValidate_Failed"
                },
                {
                	"key": "type",
                	"stringValue": "EmrActivity"
                },
                {
                	"key": "dependsOn",
                	"refValue": "Activity_TeraSort"                
				},
                {	
                	"key": "step",
                	"stringValue": 	"/home/hadoop/hadoop-examples.jar,teravalidate,/mnt/var/terasort/#{myDataSizeForTest}/output,/mnt/var/terasort/#{myDataSizeForTest}/validate"
                },
            ]
    	},    	
        {
            "id": "Activity_Process_JHIST",
            "name": "Process_JHIST",
            "fields": [
                {
                	"key": "schedule",
                	"refValue": "DefaultSchedule"
                },
                {
                	"key": "runsOn",
                	"refValue": "EmrCluster"
                },
                {
                	"key": "onSuccess",
                	"refValue": "Action_Process_JHIST_Finished"
                },
                {
                	"key": "onFail",
                	"refValue": "Action_Process_JHIST_Failed"
                },
                {
                	"key": "type",
                	"stringValue": "ShellCommandActivity"
                },
                {
                	"key": "dependsOn",
                	"refValue": "Activity_TeraValidate"                
				},
                {	
                	"key": "scriptUri",
                	"stringValue": 	"s3://finra-emr/test-scripts/terasort-jhist.sh"
                },
            ]
    	},    	
        {
            "id": "Action_TeraSort_Finished",
            "name": "#{myActivity3}-#{myDataSizeForTest}-JobNotice-Finished",
            "fields": [
                {
               		"key": "message",
					"stringValue": "The TeraSort 10GB Benchmark job has completed."
#
# Attempting to add parameters to the SNS notifications.
#
#                	"stringValue": "The #{node.myActivity3} #{node.myDataSizeForTest} Benchmark job has completed. Data Size for Test: #{node.myDataSizeForTest}, Number used to set data size for TeraGen: #{node.myTeraGenNumber}, Activity 1: #{node.myActivity1}, Activity 2: #{node.myActivity2}, Activity 3: #{node.myActivity3}, Activity 4: #{node.myActivity4}, Activity 5: #{node.myActivity5}, S3 Bucket for Test Logs & Results: #{node.myS3BucketLogLocation}, Benchmark Test Tag: #{node.myBenchmarkTestTag}, Benchmark Test Id: #{node.myBenchmarkTestId}, Core Instance Count: #{node.myCoreInstanceCount}, Core Instance Type: #{node.myCoreInstanceType}, Master Instance Type: #{node.myMasterInstanceType}, AMI Version: #{node.myAmiVersion}, Subnet Id: #{node.mySubnetId}, SSH Key Pair: #{node.myKeyPair}, Topic ARN: #{node.myTopicARN), Data Pipeline Role: #{node.myRole}, EMR Resource Role: #{node.myEMRResourceRole}, EMR Bootstrap Action 1: #{node.myBootstrapAction1}, EMR Bootstrap Action 2: #{node.myBootstrapAction2}"
                 },
                {               	
                	"key": "subject",
                	"stringValue": "#{myActivity3} Finished"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_TeraSort_Failed",
            "name": "#{myActivity3}-#{myDataSizeForTest}-JobNotice-Failed",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "The TeraSort 10GB Benchmark job failed."
                 },
                {               	
                	"key": "subject",
                	"stringValue": "#{myActivity3} Failed"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_TeraGen_Finished",
            "name": "#{myActivity2}-#{myDataSizeForTest}-JobNotice-Finished",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "The TeraGen 10GB Benchmark job has completed"
                 },
                {               	
                	"key": "subject",
                	"stringValue": "#{myActivity2} Finished"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_TeraGen_Failed",
            "name": "#{myActivity2}-#{myDataSizeForTest}-JobNotice-Failed",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "The TeraGen 10GB Benchmark job failed."
                 },
                {               	
                	"key": "subject",
                	"stringValue": "#{myActivity2} Failed"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_TeraValidate_Finished",
            "name": "#{myActivity4}-#{myDataSizeForTest}-JobNotice-Finished",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "The TeraSort 10GB Benchmark job has completedBenchmark job has completed."
                 },
                {               	
                	"key": "subject",
                	"stringValue": "#{myActivity4} Finished"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_TeraValidate_Failed",
            "name": "#{myActivity4}-#{myDataSizeForTest}-JobNotice-Failed",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "The TeraValidate 10GB Benchmark job failed. Benchmark job has completed."
                 },
                {               	
                	"key": "subject",
                	"stringValue": "#{myActivity4} Failed"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_Process_JHIST_Finished",
            "name": "Process-JHIST-Finished",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "JHIST Processing has completed."
                 },
                {               	
                	"key": "subject",
                	"stringValue": "JHIST Processing Finished"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "Action_Process_JHIST_Failed",
            "name": "Process-JHIST-Failed",
            "fields": [
                {
               		"key": "message",
                	"stringValue": "JHIST Processing failed."
                 },
                {               	
                	"key": "subject",
                	"stringValue": "JHIST Processing Failed"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "topicArn",
                	"stringValue": "#{myTopicARN}"
                },
                {
                	"key": "type",
                	"stringValue": "SnsAlarm"
                },
            ]
        },
        {
            "id": "EmrCluster",
            "name": "TeraSortEmrCluster1",
            "fields": [
                {
                	"key": "type",
                	"stringValue": "EmrCluster"
                },
                {
                	"key": "terminateAfter",
                	"stringValue": "1 Days"
                },
                {
                	"key": "amiVersion",
                	"stringValue": "#{myAmiVersion}"
                },
                {
                	"key": "subnetId",
                	"stringValue": "#{mySubnetId}"
                },
                {
                	"key": "schedule",
                	"refValue": "DefaultSchedule"
                },
                {
                	"key": "masterInstanceType",
                	"stringValue": "#{myMasterInstanceType}"
                },
                {
                	"key": "masterInstanceBidPrice",
                	"stringValue": "#{myMasterInstanceBidPrice}"
                },
                {
                	"key": "coreInstanceType",
                	 "stringValue": "#{myCoreInstanceType}"
                },
                {
                	"key": "coreInstanceBidPrice",
                	 "stringValue": "#{myCoreInstanceBidPrice}"
                },
                {
                	"key": "coreInstanceCount",
                	 "stringValue": "#{myCoreInstanceCount}"
                },
                {
                	"key": "keyPair",
                	"stringValue": "#{myKeyPair}"
                },
                {
                	"key": "enableDebugging",
                	"stringValue": "true"
                },
                {
                	"key": "bootstrapAction",
                	"stringValue": "#{myBootstrapAction1}"
                },
                {
                	"key": "bootstrapAction",
                	"stringValue": "#{myBootstrapAction2}"
                },
            ]
        },
        {
            "id": "DefaultSchedule",
            "name": "Every Day",
            "fields": [
                {
                	"key": "startAt",
                	"stringValue": "FIRST_ACTIVATION_DATE_TIME"
                },
                {
                	"key": "type",
                	"stringValue": "Schedule"
                },
                {
                	"key": "period",
                	"stringValue": "1 Day"
                },
			]
        },
        {
            "id": "Default",
            "name": "Default",
            "fields": [
                {
                	"key": "scheduleType",
                	"stringValue": "cron"
                },
                {
                	"key": "failureAndRerunMode",
                	"stringValue": "CASCADE"
                },
                {
                	"key": "schedule",
                	"refValue": "DefaultSchedule"
                },
                {
                	"key": "pipelineLogUri",
                	"stringValue": "s3://#{myS3BucketLogLocation}/test-results/#{myBenchmarkTestTag}-Test-#{myBenchmarkTestId}/logs"
#
# Attempting to add parameters to the SNS notifications.
#                	"stringValue": "s3://#{myS3BucketLogLocation}/test-results/#{node.@scheduledStartTime.format('MM-dd-YYYY_hh-mm')}-#{myBenchmarkTestTag}-Test-#{myBenchmarkTestId}/logs"
#                	"stringValue": "s3://#{myS3BucketLogLocation}/test-results/#{format(myDateTime, 'MM-dd-YYYY_hh')}-#{myBenchmarkTestTag}-Test-#{myBenchmarkTestId}/logs"
                },
                {
                	"key": "role",
                	"stringValue": "#{myRole}"
                },
                {
                	"key": "resourceRole",
                	"stringValue": "#{myEMRResourceRole}"
                }
            ]
        },
    ]       
# --------------------------------------------------------------
# Define Parameter Objects
# --------------------------------------------------------------
theParameterObjects = [
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Data Size for Test"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myDataSizeForTest"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Number used to set data size for TeraGen Activity. 8 zeros=10GB, 9=100GB, 10= 1TB"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myTeraGenNumber"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Activity 1"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myActivity1"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Activity 2"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myActivity2"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Activity 3"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myActivity3"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Activity 4"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myActivity4"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Activity 5"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myActivity5"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "S3 Bucket for Test Logs & Results"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}					
			],
			"id": "myS3BucketLogLocation"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Benchmark Test Tag"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myBenchmarkTestTag"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Benchmark Test Id"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myBenchmarkTestId"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Core Instance Count"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myCoreInstanceCount"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Core Instance Type"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myCoreInstanceType"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Core Instance Bid Price"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myCoreInstanceBidPrice"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Master Instance Type"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myMasterInstanceType"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Master Instance Bid Price"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myMasterInstanceBidPrice"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "AMI Version"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myAmiVersion"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Subnet Id"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "mySubnetId"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "SSH Key Pair"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myKeyPair"
		},	
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Topic ARN for SNS Notifications"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myTopicARN"
		},	
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "Data Pipeline Role"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myRole"
		},
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "EMR Resource Role"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myEMRResourceRole"
		},	
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "EMR Bootstrap Action 1"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myBootstrapAction1"
		},	
		{
			"attributes": [
				{
					"key": "Description",
					"stringValue": "EMR Bootstrap Action 2"
				},
				{
					"key": "Type",
					"stringValue": "String"
				}
			],
			"id": "myBootstrapAction2"
		}	

	]
		
# --------------------------------------------------------------
# Define Parameter Values
# --------------------------------------------------------------
theParameterValues = [
		{
            "id": "myDataSizeForTest",
            "stringValue": "10GB"
        },
		{
            "id": "myTeraGenNumber",
            "stringValue": "100000000"
        },
		{
            "id": "myActivity1",
            "stringValue": "PreTestSetup"
        },
		{
            "id": "myActivity2",
            "stringValue": "TeraGen"
        },
		{
            "id": "myActivity3",
            "stringValue": "TeraSort"
        },
		{
            "id": "myActivity4",
            "stringValue": "TeraValidate"
        },
		{
            "id": "myActivity5",
            "stringValue": "JHISTProcess"
        },
		{
            "id": "myS3BucketLogLocation",
            "stringValue": "finra-emr"
        },
        {
            "id": "myBenchmarkTestTag",
            "stringValue": "FINRA-TeraSort-EFS"
        },
        {
            "id": "myBenchmarkTestId",
            "stringValue": "17"
        },
        {
             "id": "myCoreInstanceCount",
 	         "stringValue": "1"
  	    },
  	    {
             "id": "myCoreInstanceType",
 	         "stringValue": "c3.xlarge"
  	    },
  	    {
             "id": "myCoreInstanceBidPrice",
 	         "stringValue": "0.10"
  	    },  	    
  	    {
             "id": "myMasterInstanceType",
 	         "stringValue": "c3.xlarge"
  	    },  	    
  	    {
             "id": "myMasterInstanceBidPrice",
 	         "stringValue": "0.10"
  	    },  	    
  	    {
             "id": "myAmiVersion",
 	         "stringValue": "3.7.0"
  	    },
  	    {
             "id": "mySubnetId",
 	         "stringValue": "subnet-1d7e285b"
  	    },
  	    {
             "id": "myKeyPair",
 	         "stringValue": "finra-lab"
  	    },
  	    {
             "id": "myBootstrapAction1",
 	         "stringValue": "s3://finra-emr/bootstraps/setup_efs.sh"
  	    },
 	    {
            "id": "myBootstrapAction2",
	         "stringValue": "s3://elasticmapreduce/bootstrap-actions/configure-hadoop,--hdfs-key-value, dfs.data.dir=/dfs,--hdfs-key-value,dfs.replication=1"
  	    },
  	    {
             "id": "myTopicARN",
 	         "stringValue": "arn:aws:sns:us-east-1:153806240718:FINRA-DPL_EMR"
  	    },
        {
        	"id": "myRole",
            "stringValue": "DataPipelineDefaultRole"
        },
        {
            "id": "myEMRResourceRole",
            "stringValue": "DataPipelineDefaultResourceRole"
        }
  	    
    ]       

# --------------------------------------------------------------
# Create the Pipeline with Tags
# --------------------------------------------------------------
createResponse = datapipeline.create_pipeline(name="FINRA-TeraSort-10GB-EFS-TestID-17",
    uniqueId="FINRA-TeraSort-10GB-EFS-TestID-17",
    description="Template for launching FINRA TeraSort Benchmark Test",
    tags=[{"key":"Customer", "value": "FINRA"},
    {"key": "DPL Template","value": "FINRA-TeraSort-10GB-EFS-TestID-17"}])
# pipelineId = createResponse['pipelineId']
# print pipelineId

# --------------------------------------------------------------
# Validate Pipeline Definition
# Don't really need this since Boto is performing validation checks
# --------------------------------------------------------------

validateResponse = datapipeline.validate_pipeline_definition(pipelineId=createResponse['pipelineId'], 			  
	pipelineObjects=thePipelineObjects, parameterValues=theParameterValues, parameterObjects=theParameterObjects
)

# --------------------------------------------------------------
# Create (PUT) Pipeline Definition
# --------------------------------------------------------------
putResponse = datapipeline.put_pipeline_definition(pipelineId=createResponse['pipelineId'], 
	pipelineObjects=thePipelineObjects, parameterValues=theParameterValues, parameterObjects=theParameterObjects
)

# --------------------------------------------------------------
# Activate Pipeline
# --------------------------------------------------------------
activateResponse = datapipeline.activate_pipeline(pipelineId=createResponse['pipelineId'])