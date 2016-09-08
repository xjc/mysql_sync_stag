#!/usr/bin/env bash

#log name
LOG_FILE="mysql_sync_"$(date +"%Y%m%d%H%M%S").log
BASE_DIR=$(pwd)

function test(){
    a1="$1"
    a2="$2"
    echo "aaa"
    echo -ne "$a1""\t""$a2"
}

function record_log() {
    msg="$1"
    time_str=$(date +"%Y-%m-%d %T")
    echo -ne "${time_str}""\t""$msg""\n" | tee -a $LOG_FILE
}

#check if target table structure is same as the source table
function check_table_structure() {
    return 0
}

#you know that, as you have seen
function drop_table() {
    local mysql_con="$1"
    local db_name="$2"
    local table_name="$3"
    local table_sql="drop table if exists ${db_name}.${table_name}" 
    record_log "begin to drop table ""${db_name}.${table_name}" 

    echo "$table_sql" | eval "$mysql_con"
    [ $? -ne 0 ] && (ecord_log "ERRORS: ""$table_sql"; exit -1)
    record_log "SUCCESSFUL: ""$table_sql"
}

#you know that, as you have seen
function truncate_table() {
    local mysql_con="$1"
    local db_name="$2"
    local table_name="$3"
    local table_sql="truncate table ${db_name}.${table_name}" 
    record_log "begin to truncate table ""${db_name}.${table_name}" 

    echo "$table_sql" | eval "$mysql_con"
    [ $? -ne 0 ] && (ecord_log "ERRORS: ""$table_sql"; exit -1)
    record_log "SUCCESSFUL: ""$table_sql"

#    if [ $? -ne 0 ];
#    then
#        record_log "ERRORS: ""$truncate_table_sql"
#        exit 0
#    else 
#        record_log "SUCCESSFUL: ""$truncate_table_sql"
#    fi
#    return 0
}

function get_ddl_sql() {
    local mysql_con="$1"
    local db_name="$2"
    local table_name="$3"
    local table_sql="show create table ${db_name}.${table_name} \G" 
    ddl_file="$1.$2.$3"


    record_log "begin to ddl: ""${db_name}.${table_name}""\n""$table_sql"
    echo "$table_sql" | eval "$mysql_con" | 
       awk -v begin_num=9999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] begin_num 
              }
          if(NR>begin_num){print $0} 
        }' | tee -a >./result.sql
}

#you know that
function create_table() {
    local mysql_con="$1"
    local ddl_sql="$2"
    record_log "begin to create table"
    record_log "$ddl_sql"


    return 0
}

#when you sync a table, check the num of rows of the target table and source table 
function check_sync_result() {
    return 0
}

#multi tables sync
function load_config_file() {
    return 0
}



function sync_single_table() {
    return 0
}

function sync_multi_tables() {
    return 0
}

test xyz def
