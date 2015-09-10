#!/usr/bin/env python
"""
Create a DataPipeline pipeline using the specified template json and activate the pipeline.
"""
import sh
import getopt
import json
import sys
import uuid



def create_put_activate_pipeline(template_file_path):
    """
       :param template_file_path: string.
    """
    pipelineFilePath = "file://" + template_file_path
    uniqueId = "TeraSort" + str(uuid.uuid4().fields[-1])[:5]
    print("New pipeline from pipeline template: " + pipelineFilePath)

    print("Create Pipeline")
    cr = sh.aws("datapipeline", "create-pipeline", "--name", "TeraSort-10GB", "--unique-id", uniqueId, "--tags", "key=DPLTemplate,value=TeraSort-10GB-Template-v7")
    print(cr)
    pipelineId = json.loads(str(cr))['pipelineId']

    print("Put pipeline definition")
    pr = sh.aws("datapipeline", "put-pipeline-definition", "--pipeline-id", pipelineId, "--pipeline-definition", pipelineFilePath)
    print(pr)

    print("Activate pipeline")
    ar = sh.aws("datapipeline", "activate-pipeline", "--pipeline-id", pipelineId)
    print(ar)
    print("Activated pipeline")



def usage():
    print("Usage: %s -t template_file_path" % sys.argv[0])

if __name__ == "__main__":
    template_file_path = None
    try:
        opts, args = getopt.getopt(sys.argv[1:], "t:",
                                   ["template_file_path="])
    except getopt.GetoptError as e:
        print (str(e))
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-t", "--template_file_path"):
            template_file_path = arg

    if template_file_path is None:
        usage()
        sys.exit(2)

    create_put_activate_pipeline(template_file_path)