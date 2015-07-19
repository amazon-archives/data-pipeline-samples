#!/bin/bash

sample_db_host="dpl-sample-db.cavqlm7jzxfc.us-east-1.rds.amazonaws.com"
sample_database="millionsongs"
sample_table="songs"
sample_target_dir="s3://data-pipeline-samples/sqoop-activity/songs-`date +"%m-%d-%Y-%T" | sed "s/:/-/g"`"
sample_user="dpl-sample-user"

host=$sample_db_host
database=$sample_database
table=$sample_table
target=$sample_target_dir
user=$sample_user
password=""

if [ -d "$1" ]
then
    host=$1
fi

if [ -d "$2" ]
then
	database=$2
fi

if [ -d "$3" ]
then
	table=$3
fi

if [ -d "$4" ]
then
	target=$4
fi

if [ -d "$5" ]
then
	user=$5
fi

if [ -d "$6" ]
then
	password="--password $6"
fi

sqoop import --connect jdbc:mysql://$host/$database --table $table --target-dir $target  --username $user $password