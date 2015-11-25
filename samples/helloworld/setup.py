import sys
sys.path.append("../../setup")

from stacker import Stacker

s = Stacker(
    "dpl-samples-hello-world",
    {
        "Resources": {
            "S3Bucket": {
                "Type": "AWS::S3::Bucket",
                "DeletionPolicy": "Delete"
            }
        }
    })

s.run(sys.argv)
