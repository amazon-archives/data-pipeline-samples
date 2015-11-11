package com.amazonaws.datapipelinesamples.ddbexport;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.services.datapipeline.DataPipelineClient;

import java.util.Map;

public class Main {

    private static DataPipelineClient dataPipelineClient;

    public static void main(String args[]) {
        Map<String, String> params = CommandLineArgParser.parseParameters(args);

        dataPipelineClient = getClient(params.get("credentialsFile"));

        String pipelineId = DDBExportPipelineCreator.createPipeline(dataPipelineClient);

        DDBExportPipelineCreator.putPipelineDefinition(dataPipelineClient, pipelineId, params);

        DDBExportPipelineCreator.activatePipeline(dataPipelineClient, pipelineId);

        PipelineMonitor.monitorPipelineUntilCompleted(dataPipelineClient, pipelineId, "TableBackupActivity");
    }

    private static DataPipelineClient getClient(final String profileName) {
        AWSCredentials credentials = new ProfileCredentialsProvider(profileName, "default").getCredentials();
        return new DataPipelineClient(credentials);
    }
}