#!/bin/bash
#Simple boostsrap script to install stable sqoop in EMR/DataPipeline environments
#####VARIABLES#####
SQOOPDIR=/home/hadoop/.versions/
S3BASE=s3://rapmeduce/data/
SQOOPDIST='sqoop-1.4.6.bin__hadoop-0.23.tar.gz'
SQOOPTARDIR=$SQOOPDIR$SQOOPDIST
S3SQOOPKEY=$S3BASE$SQOOPDIST
TASKRUNNERDIR='/mnt/taskRunner'

#This is for DataPipeline, so if we don't Have Taskrunner we won't get the mysql jdbc jar.
if [ ! -d $TASKRUNNERDIR ]; then
	echo "TaskRunner not found, please launch an EMR cluster with TaskRunner, or manually create the /mnt/taskRunner directory"
	exit 1
fi


#fetch Sqoop file from s3
aws s3 cp $S3SQOOPKEY $SQOOPDIR
#cd into .version directory to ensure the Tar command works properly
cd $SQOOPDIR
tar -zxvf $SQOOPTARDIR
#This gets rid of the tar.gz and gives a better variable name for sqoop
SQOOPFINALDIR=`ls $SQOOPTARDIR | cut -d'.' -f -6`
#Symlink the install to the /home/hadoop/sqoop/
ln -s $SQOOPFINALDIR"/" /home/hadoop/sqoop

#link sqoop lib directory to taskrunner jars
cp $TASKRUNNERDIR/common/* $SQOOPFINALDIR/lib/
if [ ! -f $SQOOPFINALDIR/lib/mysql-connector-java-bin.jar ];then
	echo "mysql-connector-java-bin.jar not found. This is necessary for JDBC connections"
fi

#Add sqoop to path
PATH=$PATH:/home/hadoop/sqoop/bin
export PATH

exit 0