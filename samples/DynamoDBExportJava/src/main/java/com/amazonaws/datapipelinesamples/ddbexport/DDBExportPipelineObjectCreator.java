package com.amazonaws.datapipelinesamples.ddbexport;

import com.amazonaws.services.datapipeline.model.Field;
import com.amazonaws.services.datapipeline.model.PipelineObject;
import com.google.common.collect.Lists;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DDBExportPipelineObjectCreator {

    public static PipelineObject getDefault() {
        String name = "Default";
        String id = "Default";

        Field type = new Field().withKey("scheduleType").withStringValue("CRON");
        Field scheduleType = new Field().withKey("schedule").withRefValue("Schedule");
        Field failureAndRerunMode = new Field().withKey("failureAndRerunMode").withStringValue("CASCADE");
        Field role = new Field().withKey("role").withStringValue("DataPipelineDefaultRole");
        Field resourceRole = new Field().withKey("resourceRole").withStringValue("DataPipelineDefaultResourceRole");
        Field pipelineLogURI = new Field().withKey("pipelineLogUri").withStringValue("#{myLogsS3Location}");

        List<Field> fieldsList = Lists.newArrayList(type, scheduleType, failureAndRerunMode,
                role, resourceRole, pipelineLogURI);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }

    public static PipelineObject getRunOnceSchedule() {
        String name = "RunOnceSchedule";
        String id = "Schedule";

        Field type = new Field().withKey("type").withStringValue("Schedule");
        Field startAt = new Field().withKey("startAt").withStringValue("FIRST_ACTIVATION_DATE_TIME");
        Field period = new Field().withKey("period").withStringValue("1 day");
        Field occurrences = new Field().withKey("occurrences").withStringValue("1");

        List<Field> fieldsList = Lists.newArrayList(type, startAt, period, occurrences);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }

    public static PipelineObject getRunDailySchedule() {
        String name = "DailySchedule";
        String id = "Schedule";

        Field type = new Field().withKey("type").withStringValue("Schedule");
        Field startAt = new Field().withKey("startAt").withStringValue("FIRST_ACTIVATION_DATE_TIME");
        Field period = new Field().withKey("period").withStringValue("1 day");

        List<Field> fieldsList = Lists.newArrayList(type, startAt, period);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }

    public static PipelineObject getDDBSourceTable() {
        String name = "DDBSourceTable";
        String id = "DDBSourceTable";

        Field type = new Field().withKey("type").withStringValue("DynamoDBDataNode");
        Field tableName = new Field().withKey("tableName").withStringValue("#{myDDBTableName}");
        Field readThroughputPercent = new Field().withKey("readThroughputPercent")
                .withStringValue("#{myDDBReadThroughputRatio}");

        List<Field> fieldsList = Lists.newArrayList(tableName, type, readThroughputPercent);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }

    public static PipelineObject getS3BackupLocation() {
        String name = "S3BackupLocation";
        String id = "S3BackupLocation";

        Field type = new Field().withKey("type").withStringValue("S3DataNode");
        Field directoryPath = new Field().withKey("directoryPath")
                .withStringValue("#{myOutputS3Location}#{format(@scheduledStartTime, 'YYYY-MM-dd-HH-mm-ss')}");

        List<Field> fieldsList = Lists.newArrayList(type, directoryPath);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }

    public static PipelineObject getEMRCluster() {
        String name = "EmrClusterForBackup";
        String id = "EmrClusterForBackup";

        Field type = new Field().withKey("type").withStringValue("EmrCluster");
        Field amiVersion = new Field().withKey("amiVersion").withStringValue("3.10.0");
        Field masterInstanceType = new Field().withKey("masterInstanceType").withStringValue("m3.xlarge");
        Field coreInstanceType = new Field().withKey("coreInstanceType").withStringValue("m3.xlarge");
        Field coreInstanceCount = new Field().withKey("coreInstanceCount").withStringValue("1");
        Field region = new Field().withKey("region").withStringValue("#{myDDBRegion}");
        Field terminateAfter = new Field().withKey("terminateAfter").withStringValue("12 hours");
        Field bootstrapAction = new Field().withKey("bootstrapAction").withStringValue("s3://elasticmapreduce" +
                "/bootstrap-actions/configure-hadoop, --yarn-key-value,yarn.nodemanager.resource.memory-mb=11520," +
                "--yarn-key-value,yarn.scheduler.maximum-allocation-mb=11520," +
                "--yarn-key-value,yarn.scheduler.minimum-allocation-mb=1440," +
                "--yarn-key-value,yarn.app.mapreduce.am.resource.mb=2880," +
                "--mapred-key-value,mapreduce.map.memory.mb=5760," +
                "--mapred-key-value,mapreduce.map.java.opts=-Xmx4608M," +
                "--mapred-key-value,mapreduce.reduce.memory.mb=2880," +
                "--mapred-key-value,mapreduce.reduce.java.opts=-Xmx2304m," +
                "--mapred-key-value,mapreduce.map.speculative=false");

        List<Field> fieldsList = Lists.newArrayList(type, amiVersion, masterInstanceType,
                coreInstanceCount, coreInstanceType, region, terminateAfter, bootstrapAction);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }

    public static PipelineObject getEMRActivity() {
        String name = "TableBackupActivity";
        String id = "TableBackupActivity";

        Field type = new Field().withKey("type").withStringValue("EmrActivity");
        Field input = new Field().withKey("input").withRefValue("DDBSourceTable");
        Field output = new Field().withKey("output").withRefValue("S3BackupLocation");
        Field runsOn = new Field().withKey("runsOn").withRefValue("EmrClusterForBackup");
        Field resizeClusterBeforeRunning = new Field().withKey("resizeClusterBeforeRunning")
                .withStringValue("#{myResizeClusterBeforeRunning}");
        Field maximumRetries = new Field().withKey("maximumRetries").withStringValue("2");
        Field step = new Field().withKey("step").withStringValue("s3://dynamodb-emr-#{myDDBRegion}/emr-ddb-storage-" +
                "handler/2.1.0/emr-ddb-2.1.0.jar,org.apache.hadoop.dynamodb.tools.DynamoDbExport," +
                "#{output.directoryPath},#{input.tableName},#{input.readThroughputPercent}");

        List<Field> fieldsList = Lists.newArrayList(type, input, output, runsOn,
                resizeClusterBeforeRunning, maximumRetries, step);

        return new PipelineObject().withName(name).withId(id).withFields(fieldsList);
    }
}
