package com.amazonaws.datapipelinesamples.ddbexport;

import com.amazonaws.services.datapipeline.DataPipelineClient;
import com.amazonaws.services.datapipeline.model.DescribeObjectsRequest;
import com.amazonaws.services.datapipeline.model.DescribeObjectsResult;
import com.amazonaws.services.datapipeline.model.Field;
import com.amazonaws.services.datapipeline.model.QueryObjectsRequest;
import com.amazonaws.services.datapipeline.model.QueryObjectsResult;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.Timer;
import java.util.TimerTask;
import java.util.stream.Collectors;

public class PipelineMonitor {

    private static final Logger logger = LogManager.getLogger(DDBExportPipelineCreator.class);

    public static void monitorPipelineUntilCompleted(final DataPipelineClient dataPipelineClient,
                                                     final String pipelineId, final String activityName) {
        Timer timer = new Timer();
        int thirtySeconds = 30 * 1000;
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                QueryObjectsRequest queryObjectsRequest = new QueryObjectsRequest().withPipelineId(pipelineId)
                        .withSphere("INSTANCE");
                QueryObjectsResult result = dataPipelineClient.queryObjects(queryObjectsRequest);

                if(result.getIds().size() <= 0) {
                    logger.info("Creating pipeline object execution graph");
                    return;
                }

                String emrActivityId = result.getIds().stream().filter(r -> r.contains(activityName))
                        .collect(Collectors.joining("\n"));
                DescribeObjectsResult describeObjectsResult = dataPipelineClient
                        .describeObjects(new DescribeObjectsRequest().withObjectIds(emrActivityId)
                                .withPipelineId(pipelineId));

                String status = "";
                for(Field field : describeObjectsResult.getPipelineObjects().get(0).getFields()) {
                    if (field.getKey().equals("@status")) {
                        logger.info(field.getKey() + "=" + field.getStringValue());
                        status = field.getStringValue();
                    }
                }

                if (status.equals("CANCELED") || status.equals("FINISHED") || status.equals("FAILED")) {
                    this.cancel();
                    timer.cancel();
                }
            }
        }, 0, thirtySeconds);
    }
}
