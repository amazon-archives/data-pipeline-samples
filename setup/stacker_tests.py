import botocore, time, unittest
import stacker

from unittest.mock import Mock
from threading import Thread



class StatusChanger(object):

    def __init__(self, end_status, change_after_seconds, start_status="CREATE_IN_PROGRESS"):
        self.creation_time = time.time()
        self.stack_status = start_status
        self.end_status = end_status
        self.change_after_seconds = change_after_seconds

        self.resource_summaries = Mock()
        self.resource_summaries.all = Mock(return_value=[])

    def reload(self):
        call_time = time.time()
        if call_time - self.creation_time > self.change_after_seconds:
            self.stack_status = self.end_status


class TestStacker(unittest.TestCase):

    def setUp(self):
        self.cloudformation = Mock()

    def test_stack_status_change(self):
        stack = StatusChanger("CREATE_COMPLETE", 1)
        stacker.wait_for_status_change(stack)
        self.assertEqual(stack.stack_status, "CREATE_COMPLETE")

    def test_unexpected_status(self):
        self.cloudformation.create_stack = Mock(return_value=StatusChanger("UNEXPECTED", 1))
        stkr = stacker.Stacker("example", {}, cloudformation=self.cloudformation)
        self.assertFalse(stkr.setup())

    def test_client_error(self):
        error_response = {
            "Error": {
                "Code": "ExampleClientError",
                "Message": "Something happened"
            }
        }
        self.cloudformation.create_stack = Mock(side_effect=botocore.exceptions.ClientError(error_response, "CreateStack"))
        stkr = stacker.Stacker("example", {}, cloudformation=self.cloudformation)
        self.assertFalse(stkr.setup())

    def test_stack_on_complete_callback(self):
        self.cloudformation.create_stack = Mock(return_value=StatusChanger("CREATE_COMPLETE", 0.1))
        stkr = stacker.Stacker("example", {}, cloudformation=self.cloudformation)

        mem = {"called": False}
        def callback():
            mem["called"] = True

        stkr.setup(on_complete=callback)
        self.assertTrue(mem["called"])

        

if __name__ == "__main__":
    unittest.main()
