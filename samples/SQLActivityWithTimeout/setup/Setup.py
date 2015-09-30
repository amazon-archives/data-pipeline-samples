from SQLActivitySample import SQLActivitySample
from Utilities import check_working_directory

import argparse
import sys


if __name__ == '__main__':
    check_working_directory()
    parser = argparse.ArgumentParser(description='Setup for SQLActivity pipeline sample')
    args = parser.parse_args()

    sample = SQLActivitySample()
    sample.create_rds_instance()
    sample.run_setup_datapipeline()
    sample.print_setup_results()
