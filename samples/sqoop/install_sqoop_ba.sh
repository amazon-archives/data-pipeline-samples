#!/bin/bash
#Simple boostsrap script to install stable sqoop in EMR/DataPipeline environments
#####VARIABLES#####
SQOOPDIR=/home/hadoop/.versions/
S3BASE=s3://data-pipeline-samples/sqoop-activity/
SQOOPDIST='sqoop-1.4.6.bin__hadoop-0.23.tar.gz'
SQOOPTARDIR=$SQOOPDIR$SQOOPDIST
S3SQOOPKEY=$S3BASE$SQOOPDIST
MQLCONNECTOR='mysql-connector-java-bin.jar'

#fetch Sqoop file from s3
aws s3 cp $S3SQOOPKEY $SQOOPDIR


#cd into .version directory to ensure the Tar command works properly
cd $SQOOPDIR
tar -zxvf $SQOOPTARDIR
#This gets rid of the tar.gz and gives a better variable name for sqoop
SQOOPFINALDIR=`ls $SQOOPTARDIR | cut -d'.' -f -6`
#Symlink the install to the /home/hadoop/sqoop/
ln -s $SQOOPFINALDIR"/" /home/hadoop/sqoop
#cp /home/hadoop/$MQLCONNECTOR /home/hadoop/scoop/lib/
aws s3 cp $S3BASE$MQLCONNECTOR /home/hadoop/sqoop/lib/$MQLCONNECTOR

sudo ln -s /home/hadoop/sqoop/bin/sqoop /usr/bin/sqoop