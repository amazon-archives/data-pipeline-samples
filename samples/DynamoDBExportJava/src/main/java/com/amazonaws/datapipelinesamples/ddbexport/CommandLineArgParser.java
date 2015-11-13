package com.amazonaws.datapipelinesamples.ddbexport;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

public class CommandLineArgParser {
    private static final Logger logger = LogManager.getLogger(CommandLineArgParser.class);

    public static Map<String, String> parseParameters(final String[] args) {
        Options params = new Options();
        params.addOption("myDDBTableName", true, "Dynamo DB source table that will be exported (REQUIRED)");
        params.addOption("myOutputS3Location", true, "S3 bucket where the export will be stored (REQUIRED)");
        params.addOption("myLogsS3Location", true, "S3 bucket where the logs will be stored (REQUIRED)");
        params.addOption("schedule", true, "Schedule to run pipeline on. Options are: once or daily (REQUIRED)");
        params.addOption("credentialsFile", true, "Path to AWS credentials file. ex: /Users/foo/.aws/credentials " +
                "(REQUIRED)");
        params.addOption("myDDBRegion", true, "Region to run pipeline in. Default: us-east-1 (Optional)");

        return getParamsMap(args, params);
    }

    private static Map<String, String> getParamsMap(final String[] args, final Options params) {
        CommandLineParser parser = new DefaultParser();
        CommandLine cmd;
        Map<String, String> paramsMap = new HashMap<>();

        try {
            cmd = parser.parse(params, args);
            addToMapIfPreset(cmd, "credentialsFile", true, paramsMap);
            addToMapIfPreset(cmd, "myDDBTableName", true, paramsMap);
            addToMapIfPreset(cmd, "myOutputS3Location", true, paramsMap);
            addToMapIfPreset(cmd, "myLogsS3Location", true, paramsMap);
            addToMapIfPreset(cmd, "schedule", true, paramsMap);
            addToMapIfPreset(cmd, "myDDBRegion", false, paramsMap);
        } catch (ParseException | RuntimeException e) {
            logger.error(e.getMessage());
            printHelp(params);
            throw new RuntimeException();
        }

        return paramsMap;
    }

    private static void printHelp(final Options params) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("maven", params);
    }

    private static void addToMapIfPreset(final CommandLine cmd, final String paramName, final boolean required,
                                         final Map<String,String> paramsMap) {
        if(cmd.hasOption(paramName)) {
            paramsMap.put(paramName, cmd.getOptionValue(paramName));
        } else if (required) {
            logger.error("Unable to find required parameter: " + paramName);
            throw new RuntimeException();
        }
    }
}
