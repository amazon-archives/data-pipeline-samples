import os
import sys


def check_working_directory():
    current_folder_path, current_folder_name = os.path.split(os.getcwd())
    if current_folder_name == 'RDStoRedshiftSqoop':
        os.chdir('setup')
    elif current_folder_name != 'setup':
        print 'ERROR: please run the setup script from data-pipeline-samples/samples/RDStoRedshiftSqoop/setup'
        sys.exit(0)
