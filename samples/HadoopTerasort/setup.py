import sys
sys.path.append("../../setup")

from stacker import Stacker

s = Stacker(
    "dpl-samples-hadoop-terasort",
    {
        "Resources": {
            "S3Bucket": {
                "Type": "AWS::S3::Bucket",
                "DeletionPolicy": "Delete"
            }
        }
    })

s.run(sys.argv)
