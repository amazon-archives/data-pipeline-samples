![Data Pipeline Logo](https://raw.githubusercontent.com/awslabs/data-pipeline-samples/master/setup/logo/datapipelinelogo.jpeg)

Hadoop TeraSort 10GB Sort Benchmark
====================================
This sample sets up a Data Pipeline to run a TeraSort(10GB) on an EMR cluster.
After running the TeraSort,it stores the result of daily execution in S3 along the Hadoop configuration.

# Running the pipeline template


The python driver (optional) will create and activate a pipeline from the pipeline template JSON.
The python driver is optional. You could skip the driver and use AWS CLI or Console instead.
The instructions at https://github.com/awslabs/data-pipeline-samples tell you how to create, setup, and activate a pipeline. 

##1. Ensure python 2.7 is installed.
##2. Upgrade AWS CLI

```sh
 $> sudo pip install awscli --upgrade
```

##3. Install SH python package

```sh
 $> setup/sudo pip install sh
```

##4. Edit the template (as needed).
```sh
 Example: Changing the EMR Cluster AMI. AMI version used in the template is 3.9.0.
 Bootstrap actions to configure memory, etc. Sample configuration is specified in the template.
 If the default configuration is to be used, remove the bootstrapAction field.
```


##5. In the template, provide the value for the parameter: "myPathToLogFiles".
    This is the folder under which DataPipeline publishes the log files.
    Example: "s3://aravind-terasort/dpl-logging/"
    
##6. In the template, provide the value for the parameter: "myPathToTerasortResults". 
    This is the folder under which test results are published for each run daily.
    Example: "s3://aravind-terasort/test-results"    
    

##7. Create, put and activate the pipeline by running the following driver script:    

```sh
 $> python driver/run_template.py -t TeraSortHadoopBenchmark.json
```