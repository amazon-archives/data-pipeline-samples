package com.amazonaws.datapipelinesamples.ddbexport;

import com.amazonaws.services.datapipeline.DataPipelineClient;
import com.amazonaws.services.datapipeline.model.ActivatePipelineRequest;
import com.amazonaws.services.datapipeline.model.CreatePipelineRequest;
import com.amazonaws.services.datapipeline.model.CreatePipelineResult;
import com.amazonaws.services.datapipeline.model.ParameterValue;
import com.amazonaws.services.datapipeline.model.PipelineObject;
import com.amazonaws.services.datapipeline.model.PutPipelineDefinitionRequest;
import com.amazonaws.services.datapipeline.model.PutPipelineDefinitionResult;
import com.google.common.collect.Lists;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;
import java.util.Map;
import java.util.UUID;

public class DDBExportPipelineCreator {

    private static final Logger logger = LogManager.getLogger(DDBExportPipelineCreator.class);
    private final static String name = "DDB Export Java Sample";
    private final static String uniqueId  = UUID.randomUUID().toString();

    public static String createPipeline(DataPipelineClient dataPipelineClient) {
        CreatePipelineRequest createPipelineRequest = new CreatePipelineRequest().withName(name)
                .withUniqueId(uniqueId);
        CreatePipelineResult createPipelineResult = dataPipelineClient.createPipeline(createPipelineRequest);
        String pipelineId = createPipelineResult.getPipelineId();
        logger.info("Created pipeline id: " + pipelineId);
        return pipelineId;
    }

    public static void putPipelineDefinition(final DataPipelineClient dataPipelineClient, final String pipelineId,
                                             final Map<String, String> params) {

        List<PipelineObject> pipelineObjectList = getPipelineObjects(params.get("schedule"));

        List<ParameterValue> parameterValues = getParameterValues(params);

        PutPipelineDefinitionRequest putPipelineDefinition = new PutPipelineDefinitionRequest()
                .withPipelineId(pipelineId).withParameterValues(parameterValues).withPipelineObjects(pipelineObjectList);

        PutPipelineDefinitionResult putPipelineResult = dataPipelineClient.putPipelineDefinition(putPipelineDefinition);

        if (putPipelineResult.isErrored()) {
            logger.error("Error found in pipeline definition: ");
            putPipelineResult.getValidationErrors().stream().forEach(e -> logger.error(e));
            throw new RuntimeException("Error in pipeline definition.");
        }

        if (putPipelineResult.getValidationWarnings().size() > 0) {
            logger.warn("Warnings found in definition: ");
            putPipelineResult.getValidationWarnings().stream().forEach(e -> logger.warn(e));
        }

        logger.info("Created pipeline definition");
    }

    private static List<PipelineObject> getPipelineObjects(final String scheduleType) {
        PipelineObject schedule = DDBExportPipelineObjectCreator.getRunDailySchedule();
        if(scheduleType.contains("once")) {
            schedule = DDBExportPipelineObjectCreator.getRunOnceSchedule();
        }

        PipelineObject defaultObject = DDBExportPipelineObjectCreator.getDefault();
        PipelineObject ddbSourceTable = DDBExportPipelineObjectCreator.getDDBSourceTable();
        PipelineObject s3BackupLocation = DDBExportPipelineObjectCreator.getS3BackupLocation();
        PipelineObject emrCluster = DDBExportPipelineObjectCreator.getEMRCluster();
        PipelineObject emrActivity = DDBExportPipelineObjectCreator.getEMRActivity();

        return Lists.newArrayList(schedule, defaultObject, ddbSourceTable,
                s3BackupLocation, emrCluster, emrActivity);
    }

    private static List<ParameterValue> getParameterValues(final Map<String,String> params) {
        String region = "us-east-1";
        if(params.containsKey("myDDBRegion")) {
            region = params.get("myDDBRegion");
        }

        ParameterValue ddbRegion = new ParameterValue().withId("myDDBRegion").withStringValue(region);
        ParameterValue myDDBTableName = new ParameterValue().withId("myDDBTableName")
                .withStringValue(params.get("myDDBTableName"));
        ParameterValue myDDBReadThroughputRatio = new ParameterValue().withId("myDDBReadThroughputRatio")
                .withStringValue("0.25");
        ParameterValue myOutputS3Location = new ParameterValue().withId("myOutputS3Location")
                .withStringValue(params.get("myOutputS3Location"));
        ParameterValue myLogsS3Location = new ParameterValue().withId("myLogsS3Location")
                .withStringValue(params.get("myLogsS3Location"));
        ParameterValue myResizeClusterBeforeRunning = new ParameterValue().withId("myResizeClusterBeforeRunning")
                .withStringValue("true");

        return Lists.newArrayList(ddbRegion, myDDBTableName, myDDBReadThroughputRatio, myOutputS3Location,
                myResizeClusterBeforeRunning, myLogsS3Location);
    }

    public static void activatePipeline(final DataPipelineClient dataPipelineClient, final String pipelineId) {
        ActivatePipelineRequest activatePipelineRequest = new ActivatePipelineRequest().withPipelineId(pipelineId);
        dataPipelineClient.activatePipeline(activatePipelineRequest);
        logger.info("Pipeline activated");
    }
}
