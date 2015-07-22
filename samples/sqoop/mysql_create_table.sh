#!/bin/bash

hostname=$1
database=$2
username=$3
password=$4

mysql -h $hostname -D $database -P 3306 --user=$username --password=$password -e "create table songs (track_id varchar(512) primary key not null, title text, song_id text, release_name text, artist_id text, artist_mbid text, artist_name text, duration float, artist_familiarity float, artist_hotness float, year integer)"
