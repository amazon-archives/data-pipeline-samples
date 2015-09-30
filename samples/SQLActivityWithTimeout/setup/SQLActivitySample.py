from SetupPipelineDefinition import SetupPipelineDefinitionHelper

import boto3
import re
import time


class SQLActivitySample(object):
    def __init__(self):
        self.rds_id = ""
        self.rds_endpoint = ""
        self.rds_security_group = "rds_security_group"
        self.pipeline_definition = SetupPipelineDefinitionHelper()
        self.account_id = ""
        self.pipeline_id = "test"
        self.rds_password = "Dplcustomer1"
        self.rds_username = "dplcustomer"
        self.rds_table_name = "songs"

    def create_rds_instance(self):
        self.rds_id = 'rds-sqlactivity-' + str(int(time.time()))
        print "Creating RDS database with id: " + self.rds_id

        # get account id
        iam = boto3.resource('iam')
        current_user = iam.CurrentUser()
        self.account_id = ''.join([i for i in current_user.arn if i.isdigit()])[0:12]

        client = boto3.client('rds')

        # create security group
        client.create_db_security_group(DBSecurityGroupName=self.rds_security_group,
                                        DBSecurityGroupDescription='Security group for SQL activity example')

        client.authorize_db_security_group_ingress(DBSecurityGroupName=self.rds_security_group,
                                                   EC2SecurityGroupName='default',
                                                   EC2SecurityGroupOwnerId=self.account_id)

        client.authorize_db_security_group_ingress(DBSecurityGroupName=self.rds_security_group,
                                                   EC2SecurityGroupName='elasticmapreduce-master',
                                                   EC2SecurityGroupOwnerId=self.account_id)

        client.authorize_db_security_group_ingress(DBSecurityGroupName=self.rds_security_group,
                                                   EC2SecurityGroupName='elasticmapreduce-slave',
                                                   EC2SecurityGroupOwnerId=self.account_id)

        # create db
        client.create_db_instance(DBName='millionsongs',
                                  DBInstanceIdentifier=self.rds_id,
                                  AllocatedStorage=5,
                                  DBInstanceClass='db.m1.small',
                                  Engine='MySQL',
                                  MasterUsername=self.rds_username,
                                  MasterUserPassword=self.rds_password,
                                  DBSecurityGroups=[
                                      self.rds_security_group,
                                  ])

        # wait for db to be created
        waiter = client.get_waiter('db_instance_available')

        waiter.wait(DBInstanceIdentifier=self.rds_id)

        response = client.describe_db_instances(DBInstanceIdentifier=self.rds_id)
        self.rds_endpoint = response['DBInstances'][0]['Endpoint']['Address']
        self.rds_connection_str = 'jdbc:mysql//' + self.rds_endpoint + '/millionsongs'
        print "RDS Endpoint: " + self.rds_endpoint

    def run_setup_datapipeline(self):
        pipeline_name = 'rds-sqlactivity-setup-' + str(int(time.time()))
        print "Running data setup pipeline: " + pipeline_name

        client = boto3.client('datapipeline')

        result = client.create_pipeline(name='Setup Data for SQL Activity sample',
                                        uniqueId=pipeline_name)

        self.pipeline_id = result['pipelineId']

        parameter_values = self.pipeline_definition.get_setup_pipeline_parameter_values()
        for param in parameter_values:
            if param['id'] == 'myRdsEndpoint':
                param['stringValue'] = self.rds_endpoint

        client.put_pipeline_definition(pipelineId=self.pipeline_id,
                                       pipelineObjects=self.pipeline_definition.get_setup_pipeline_objects(),
                                       parameterValues=parameter_values)

        client.activate_pipeline(pipelineId=self.pipeline_id)

        # check pipeline status
        self._check_pipeline_state(client)

    def _check_pipeline_state(self, client):
        check_counts = 0
        num_checks = 50
        while check_counts < num_checks:
            response = client.describe_pipelines(pipelineIds=[self.pipeline_id])
            if self._check_pipeline_state_iteration(response):
                return
            else:
                check_counts += 1
                time.sleep(30)

        if check_counts >= num_checks:
            print "Timed out after waiting 25 minutes for pipeline run"
            raise Exception()

    def _check_pipeline_state_iteration(self, response):
        fields = response['pipelineDescriptionList'][0]['fields']
        for field in fields:
            if field['key'] == '@pipelineState' and field['stringValue'] == 'FINISHED':
                print "Setup pipeline status: " + field['stringValue']
                return True
            elif field['key'] == '@pipelineState' and field['stringValue'] == 'FAILED':
                print "Setup pipeline status: " + field['stringValue']
                return True
            elif field['key'] == '@pipelineState':
                print "Setup pipeline status: " + field['stringValue']
                return False

    def print_setup_results(self):
        print ""
        print "Set-up complete! You are now ready to proceed with the SQL activity sample."
        print "Please refer to the sample README for instructions on how to run this sample."
        print ""
        print "You can copy and paste the following line to add the sample definition to your pipeline once it is " \
              "created (Step 2):"
        print "aws datapipeline put-pipeline-definition --pipeline-definition file://SQLActivitySample.json " \
              "--parameter-values" \
              + ' myRDSPassword=' + self.rds_password \
              + ' myRDSUsername=' + self.rds_username \
              + ' myRDSId=' + self.rds_id \
              + ' myS3LogsPath=s3://<s3-logs-path>' \
              + ' --pipeline-id <pipeline-id>'
    
        print ""
        print "If you wish to delete all the resources created for this sample, " \
              "please run the teardown script as follows"
        
        print "python setup/Teardown.py --rds-instance-id " + self.rds_id

    def destroy_rds(self, rds_id):
        print "Destroying RDS database with id: " + rds_id
        client = boto3.client('rds')
        client.delete_db_instance(DBInstanceIdentifier=rds_id,
                                  SkipFinalSnapshot=True)

        # wait for db to be deleted
        waiter = client.get_waiter('db_instance_deleted')

        waiter.wait(DBInstanceIdentifier=rds_id)

        # delete security group
        client.delete_db_security_group(DBSecurityGroupName=self.rds_security_group)
    

