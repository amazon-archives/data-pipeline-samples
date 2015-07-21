#!/bin/bash

#Make first append to Kinesis stream
java -cp .:kinesis-log4j-appender-1.0.0.jar  com.amazonaws.services.kinesis.log4j.FilePublisher access_log_1
