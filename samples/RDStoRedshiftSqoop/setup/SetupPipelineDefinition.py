import json


class SetupPipelineDefinitionHelper(object):

    def __init__(self):
        with open("setup.json", "r") as setup:
            pipeline_string = setup.read().replace('\n', '')
        self.pipeline_definition = json.loads(pipeline_string)

    def get_setup_pipeline_objects(self):
        return self.pipeline_definition['objects']

    def get_setup_pipeline_parameters(self):
        return self.pipeline_definition['parameters']

    def get_setup_pipeline_parameter_values(self):
        return self.pipeline_definition['parameterValues']
