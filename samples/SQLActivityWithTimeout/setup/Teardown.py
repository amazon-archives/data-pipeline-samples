from SQLActivitySample import SQLActivitySample
from Utilities import check_working_directory

import argparse


if __name__ == '__main__':
    check_working_directory()

    parser = argparse.ArgumentParser(description='Teardown for SQLAcivityPipeline pipeline sample')
    parser.add_argument('--rds-instance-id', action="store", dest="rds_instance_id")
    args = parser.parse_args()

    sample = SQLActivitySample()

    if args.rds_instance_id is not None:
        sample.destroy_rds(args.rds_instance_id)
