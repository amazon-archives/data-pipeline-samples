import botocore, boto3, json, sys, time


def print_resources(stack):
    resources = []
    for summary in stack.resource_summaries.all():
        resources.append((summary.resource_type, summary.physical_resource_id))

    if len(resources) == 0:
        print("No resources")
        return

    max_type_length = max(len(res[0]) for res in resources)
    format_string = "  {{:>{}}}: {{}}".format(max_type_length)

    for res in resources:
        print(format_string.format(*res))


def wait_for_status_change(stack, initial_status="CREATE_IN_PROGRESS"):
    while stack.stack_status == initial_status:
        time.sleep(0.2)
        stack.reload()


class UnexpectedStateError(Exception):

    def __init__(self, state):
        message = "Stack reached unexpected state: {}".format(state)
        super(UnexpectedStateError, self).__init__(message)


class Stacker(object):

    def __init__(self, stack_name, stack_template, timeout_in_minutes=10, cloudformation=None):
        self.stack_name = stack_name
        self.stack_template = stack_template
        self.timeout_in_minutes = timeout_in_minutes

        if cloudformation:
            self.cloudformation = cloudformation
        else:
            self.cloudformation = boto3.resource("cloudformation")


    def setup(self, on_complete=None):
        print("Creating resources for stack [{}]...".format(self.stack_name))

        try:

            stack = self.cloudformation.create_stack(
                        StackName=self.stack_name,
                        TemplateBody=json.dumps(self.stack_template),
                        TimeoutInMinutes=self.timeout_in_minutes)

            wait_for_status_change(stack)

            if stack.stack_status == "CREATE_COMPLETE":
                print_resources(stack)

                if on_complete:
                    on_complete()

                return True
            else:
                raise UnexpectedStateError(stack.stack_status)

        except (UnexpectedStateError, botocore.exceptions.ClientError) as e:
            print("ERROR: {}".format(e))
            return False


    def teardown(self):
        stacks = self.cloudformation.stacks.filter(StackName=self.stack_name)
        s3 = None

        for s in stacks:
            for r in s.resource_summaries.all():
                if r.resource_type == "AWS::S3::Bucket":
                    if not s3:
                        s3 = boto3.resource("s3")

                    bucket = s3.Bucket(r.physical_resource_id)
                    for key in bucket.objects.all():
                        key.delete()

            s.delete()

        print("Request to delete stack [{}] has been sent".format(self.stack_name))


    def run(self, args):
        if "--teardown" in args:
            self.teardown()
        else:
            self.setup()
