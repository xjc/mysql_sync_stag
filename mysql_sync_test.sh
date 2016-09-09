#!/usr/bin/env bash

#log name
LOG_FILE="mysql_sync_"$(date +"%Y%m%d%H%M%S").log
BASE_DIR=$(pwd)
SCRIPTS_DIR=$BASE_DIR/sql_scripts/
STRUCT_CHECK_ONLY=0
LIMIT_ROWS=0

function record_log() {
    msg="$1"
    time_str=$(date +"%Y-%m-%d %T")
    echo -ne "${time_str}""\t""$msg""\n" | tee -a $LOG_FILE
}

#check if target table structure is same as the source table
function check_table_structure() {
    return 0
}

# Normalise mysql output a little
norm_mysql() {                                                                                                                                                
    tr A-Z a-z |
    sed -e 's/\\n/\n/g' \
        -e 's/[ \t][ \t]*/ /g' \
        -e 's/\(engine\|auto_increment\|default charset\)=/\n\1=/g'
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
    [ $? -ne 0 ] && (record_log "ERRORS: ""$table_sql"; exit -1)
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

function sync_table_structure() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con_source="$3"
    local mysql_con_target="$4"
    local table_sql="show create table ${db_name}.${table_name} \G" 

    record_log "begin to get ddl: ""${db_name}.${table_name}""\n""$table_sql"
    ddl_sql_file=$SCRIPTS_DIR/${db_name}.${table_name}".sql"
    #echo "show create table web.test;" | eval "mysql -NB $conn_loc" | sed -e 's/.*\(create table\)/\1/i' -e 's/\\n/\n/g'
    echo "$table_sql" | eval "mysql -NB $mysql_con_source" | 
       awk -v begin_num=99999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] 
              }
          if(NR>begin_num){print $0} 
        }' | tee>$ddl_sql_file

    [ $? -ne 0 ] && (record_log "ERROR: get ddl sql, ${db_name}.${table_name}"; exit -1)
    cat $ddl_sql_file | eval "mysql -NB ${mysql_con_target}" > $LOG_FILE 2>&1
    [ $? -ne 0 ] && (record_log "ERROR: create table ${db_name}.${table_name} at the target database"; exit -1)
    
}

function compare_table_structure() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con="$3"
    local mysql_con_target="$4"
    local table_sql="show create table ${db_name}.${table_name} \G" 

    local ddl_sql_file_source=$SCRIPTS_DIR/${db_name}.${table_name}.source
    local ddl_sql_file_target=$SCRIPTS_DIR/${db_name}.${table_name}.target

    echo "$table_sql" |  | eval "mysql -NB $mysql_con_source" | 
       awk -v begin_num=99999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] 
              }
          if(NR>begin_num){print $0} 
        }' | norm_mysql | grep -v auto_increment | tee $ddl_sql_file_source
    echo "$table_sql" |  | eval "mysql -NB $mysql_con_target" | 
       awk -v begin_num=99999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] 
              }
          if(NR>begin_num){print $0} 
        }' | norm_mysql | grep -v auto_increment | tee $ddl_sql_file_target
    diff $ddl_sql_file_source $ddl_sql_file_target >$SCRIPTS_DIR/${db_name}.${table_name}.diff
    if [ $? -ne 0 ];then
        record_log "DIFFERENT TABLE STRUCTURE: ${db_name}.${table_name} \n"
        record_log "for more details, please check the diff files"
        [[ $STRUCT_CHECK_ONLY -eq 1 ]]; then 
            record_log "check_only option given, and won't sync the table structure"
        else 
            sync_table_structure $@
            sync_table_contents $@
        fi

    else
        record_log "Congratulations: the table strucure is the same\t ${db_name}.${table_name} "
    fi

}

#sync table contents using mysqldump
funciton sync_table_contents() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con_source="$3"
    local mysql_con_target="$4"

    record_log "begin to export table: $db_name.$table_name"

    local OUT_FILE="$SCRIPTS_DIR/${db_name}.${table_name}.content"
    mysqldump $mysql_con_source $db_name $table_name>$OUT_FILE 
    cat $OUT_FILE | eval "mysql -D${db_name} -NB -C" >>$LOG_FILE 2>&1
    
    if [[ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 ]];then
        record_log "SUCCESFUL: sync table contents, ${db_name}.${table_name}"
    else
        record_log "ERROR: sync table contents, ${db_name}.${table_name}"
        eixt -1
    fi

}

function sync_table_contents2() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con_source="$3"
    local mysql_con_target="$4"

    local OUT_FILE=""
    record_log "begin to export table: $db_name.$table_name"
    EXPORT_DATA_STR="select * INTO OUTFILE '$OUT_FILE'
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '\"' 
    LINES TERMINATED BY '\n'
    from ${db_name}.${table_name} "
    if [[ $LIMIT_ROWS -gt 0 ]]; then
        EXPORT_DATA_STR="$EXPORT_DATA_STR"" limit $LIMIT_ROWS "
    fi

    echo "$EXPORT_DATA_STR" | eval "mysql $mysql_con_source" >>$LOG_FILE 2>&1
    if [[ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 ]];then
        record_log "SUCCESFUL: export table contents, ${db_name}.${table_name}"
    else
        record_log "ERROR: export table contents, ${db_name}.${table_name}"
        eixt -1
    fi

    echo "load data local inpath $OUT_FILE into table ${db_name}.${table_name}
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '\"' 
    LINES TERMINATED BY '\n'" | eval "mysql $mysql_con_target" >>$LOG_FILE 2>&1

    if [[ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 ]];then
        record_log "SUCCESFUL: import table contents, ${db_name}.${table_name}"
    else
        record_log "ERROR: import table contents, ${db_name}.${table_name}"
        eixt -1
    fi

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
