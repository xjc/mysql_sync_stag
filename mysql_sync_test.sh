#!/usr/bin/env bash


BASE_DIR=$(pwd)
SCRIPTS_DIR=$BASE_DIR/mysql_sync_tmp_scripts/
LOG_DIR=$BASE_DIR/mysql_sync_log/
#log name
#LOG_FILE=$LOG_DIR/"mysql_sync_"$(date +"%Y%m%d%H%M%S").log
LOG_FILE=$LOG_DIR/"mysql_sync_"$(date +"%Y%m%d%H").log

#mysql server config
mysql_con_source=" -hlocalhost -p123456 -P3306 -uxjc"
#mysql_con_source=" -h127.0.0.1 -pjie0512 -P3306 -uxjc"
mysql_con_target=" -hlocalhost -p123456 -P3306 -uxjc"

DB_NAME=
TABLE_NAME=
STRUCT_CHECK_ONLY=0
LIMIT_ROWS=0

#tmp dir
if [ ! -d $SCRIPTS_DIR ]; then
    mkdir -p $SCRIPTS_DIR
fi
[ ! -d $LOG_DIR ] && mkdir -p $LOG_DIR

function usage() {
    
    echo "##################################################################################"
    echo "Usage: ./mysql_sync_test.sh -d DB_NAME -t TABLE_NAME -c STRUCT_CHECK_ONLY(1|0,default 0) -n LIMIT_ROWS(default 0)"
    echo "       ./mysql_sync_test.sh -d DB_NAME -t TABLE_NAME -c 1   #only check the table structure"
    echo "       ./mysql_sync_test.sh -d DB_NAME -t TABLE_NAME -n 1000  #sync the table structure and only sync 1000 rows"
    echo "PARAMETERS: " 
    echo "            STRUCT_CHECK_ONLY: default 0, 1:check only|0:check first and sync the table"
    echo "            LIMIT_ROWS         default 0, 0:sync all the table data | n(n>0) sync n rows"
    echo "eg: ./mysql_sync_test.sh -d web -t test -c 1    #only check the table struct"
    echo "    ./mysql_sync_test.sh -d web -t test   #sync the table struct and table content"
    echo "    ./mysql_sync_test.sh -d web -t test -n 100   #sync the table struct and sync 100 rows"
    echo "##################################################################################"
    
}

function record_log() {
    msg="$1"
    time_str=$(date +"%Y-%m-%d %T")
    echo -ne "${time_str}""\t""$msg""\n" | tee -a $LOG_FILE
}

#check if target table structure is same as the source table
#function check_table_structure() {
#    return 0
#}

# Normalise mysql output a little
norm_mysql() {                                                                                                                                                
    tr A-Z a-z |
    sed -e 's/\\n/\n/g' \
        -e 's/[ \t][ \t]*/ /g' \
        -e 's/\(engine\|default charset\)=/\n\1=/g'
    #    -e 's/\(engine\|auto_increment\|default charset\)=/\n\1=/g'
}

#you know that, as you have seen
function drop_table() {

    local db_name="$1"
    local table_name="$2"
    local mysql_con="$3"
    local table_sql="drop table if exists ${db_name}.${table_name}" 
    record_log "begin to drop table ""${db_name}.${table_name}" 

    echo "$table_sql" | eval "$mysql_con"
    [ $? -ne 0 ] && (ecord_log "ERRORS: ""$table_sql"; exit -1)
    record_log "SUCCESSFUL: ""$table_sql"

}

#you know that, as you have seen
function truncate_table() {

    local db_name="$1"
    local table_name="$2"
    local mysql_con="$3"
    local table_sql="truncate table ${db_name}.${table_name}" 
    record_log "begin to truncate table ""${db_name}.${table_name}" 

    echo "$table_sql" | eval "mysql $mysql_con"
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

    #recreate the table
    drop_table "$db_name" "$table_name"  "$mysql_con_target"
    cat $ddl_sql_file | eval "mysql -NB ${mysql_con_target}" >> $LOG_FILE 2>&1
    [ $? -ne 0 ] && (record_log "ERROR: create table ${db_name}.${table_name} at the target database"; exit -1)
    
}

function compare_table_structure() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con="$3"
    local mysql_con_target="$4"
    local table_sql="show create table ${db_name}.${table_name} \G" 
    if [[ $STRUCT_CHECK_ONLY -eq 1 ]]; then 
        record_log "check_only option given, and won't sync the table structure"
    fi

    local ddl_sql_file_source=$SCRIPTS_DIR/${db_name}.${table_name}.source
    local ddl_sql_file_target=$SCRIPTS_DIR/${db_name}.${table_name}.target

    echo "$table_sql" | eval "mysql -NB $mysql_con_source" | 
       awk -v begin_num=99999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] 
              }
          if(NR>begin_num){print $0} 
        }' | norm_mysql | grep -v auto_increment | tee $ddl_sql_file_source
    echo "$table_sql" | eval "mysql -NB $mysql_con_target" | 
       awk -v begin_num=99999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] 
              }
          if(NR>begin_num){print $0} 
        }' | norm_mysql | grep -v auto_increment | tee $ddl_sql_file_target
    

    DIFF_FILE=$SCRIPTS_DIR/${db_name}.${table_name}.structure.diff
    diff $ddl_sql_file_source $ddl_sql_file_target >$DIFF_FILE

    if [ $? -ne 0 ];then
        record_log "DIFFERENT TABLE STRUCTURE: ${db_name}.${table_name} \n"
        record_log "for more details, please check the diff files: $DIFF_FILE"
        return -1
    else
        record_log "Congratulations: the table strucure is the same\t ${db_name}.${table_name} "
        return 0
    fi

}

#function main_action() {
#    local db_name="$1"
#    local table_name="$2"
#    local mysql_con_source="$3"
#    local mysql_con_target="$4"
#
#    res=$(compare_table_structure "$db_name" "$table_name" "$mysql_con_source" "$mysql_con_target")
#
#
#}

#sync table contents using mysqldump
function sync_table_contents() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con_source="$3"
    local mysql_con_target="$4"

    record_log "begin to export table: $db_name.$table_name"

    local OUT_FILE="$SCRIPTS_DIR/${db_name}.${table_name}.content"
    #echo "mysqldump "$mysql_con_source" $db_name $table_name>$OUT_FILE"
    mysqldump $mysql_con_source $db_name $table_name | tee $OUT_FILE 
    #truncate_table "$DB_NAME" "$TABLE_NAME" "$mysql_con_target"
    truncate_table "$db_name" "$table_name" "$mysql_con_target"
    cat $OUT_FILE | eval "mysql ${mysql_con_target} -D${db_name} -NB -C" >>$LOG_FILE 2>&1
    
    #if [[ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 ]];then
    if [ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 ];then
        record_log "SUCCESFUL: sync table contents, ${db_name}.${table_name}"
    else
        record_log "ERROR: sync table contents, ${db_name}.${table_name}"
        exit -1
    fi

}

#export table content as text file
function sync_table_contents2() {
    local db_name="$1"
    local table_name="$2"
    local mysql_con_source="$3"
    local mysql_con_target="$4"

    local OUT_FILE="$SCRIPTS_DIR/${db_name}.${table_name}.content"
    record_log "begin to export table: $db_name.$table_name"

    #select into outfile need file priviledge
#    EXPORT_DATA_STR="select * INTO OUTFILE '$OUT_FILE'
#    FIELDS TERMINATED BY ',' 
#    OPTIONALLY ENCLOSED BY '\"' 
#    LINES TERMINATED BY '\\\n'
#    from ${db_name}.${table_name} "
    EXPORT_DATA_STR="select * from ${db_name}.${table_name} "
    if [[ $LIMIT_ROWS -gt 0 ]]; then
        EXPORT_DATA_STR="$EXPORT_DATA_STR"" limit $LIMIT_ROWS "
    fi
    record_log "EXPORT SQL: \t""$EXPORT_DATA_STR"

    #echo "$EXPORT_DATA_STR" | mysql $mysql_con_source -s -N | sed 's/\t/","/g;s/^/"/g' >$OUT_FILE 
    echo "$EXPORT_DATA_STR" | mysql $mysql_con_source -s -N | sed 's/\t/","/g;s/^/"/g;s/$/"/g' >$OUT_FILE 
    if [ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 -a ${PIPESTATUS[2]} -eq 0 ];then
        record_log "SUCCESFUL: export table contents, ${db_name}.${table_name}"
    else
        record_log "ERROR: export table contents, ${db_name}.${table_name}"
        exit -1
    fi

    truncate_table "$db_name" "$table_name" "$mysql_con_target"
    LOAD_DATA_STR="load data local infile '$OUT_FILE' into table ${db_name}.${table_name}
    FIELDS TERMINATED BY ',' 
    OPTIONALLY ENCLOSED BY '\"' 
    LINES TERMINATED BY '\n' "
    record_log "IMPORT SQL: \t""$LOAD_DATA_STR"
    
    echo "$LOAD_DATA_STR" | eval "mysql $mysql_con_target" >>$LOG_FILE 2>&1

    if [ ${PIPESTATUS[0]} -eq 0 -a ${PIPESTATUS[1]} -eq 0 ];then
        record_log "SUCCESFUL: import table contents, ${db_name}.${table_name}"
    else
        record_log "ERROR: import table contents, ${db_name}.${table_name}"
        exit -1
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
    local db_name="$1"
    local table_name="$2"
    local mysql_con_source="$3"
    local mysql_con_target="$4"

    compare_table_structure "$db_name" "$table_name" "$mysql_con_source" "$mysql_con_target"
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

#test xyz def

#while getopts :qvd:l: OPTION

if [ $# -lt 2 ]; then
    usage
    exit -1
fi
while getopts ":d:t:c:n:" opt
do
    case $opt in
        d) DB_NAME=$OPTARG;;

        t) TABLE_NAME=$OPTARG;;

        c) STRUCT_CHECK_ONLY=$OPTARG;;

        n) LIMIT_ROWS=$OPTARG;;

        ?) usage
           exit -1;;
    esac

done

[ -z $DB_NAME ] && (usage;exit -1)
[ -z $TABLE_NAME ] && (usage;exit -1)

#echo "###################"
#echo "db_name: $DB_NAME"
#echo "table_name: $TABLE_NAME"
#echo "STRUCT_CHECK_ONLY: $STRUCT_CHECK_ONLY"
#echo "LIMIT_ROWS: $LIMIT_ROWS"

compare_table_structure "$DB_NAME" "$TABLE_NAME" "$mysql_con_source" "$mysql_con_target"
compare_flag=$?

if [ $compare_flag -eq 0 ]; then
    record_log "TABLE STRUCTURE IS THE SAME: ${DB_NAME}.${TABLE_NAME}"
else
    record_log "TABLE STRUCTURE IS DIFFERENT: ${DB_NAME}.${TABLE_NAME}"
fi

[ $STRUCT_CHECK_ONLY -eq 1 ] && exit $compare_flag


if [ $compare_flag -ne 0 ]; then
    sync_table_structure "$DB_NAME" "$TABLE_NAME" "$mysql_con_source" "$mysql_con_target"
    echo 1111
fi

#truncate_table "$DB_NAME" "$TABLE_NAME" "$mysql_con_target"

if [ $LIMIT_ROWS -eq 0 ]; then
    sync_table_contents "$DB_NAME" "$TABLE_NAME" "$mysql_con_source" "$mysql_con_target"
    #sync_table_contents2 "$DB_NAME" "$TABLE_NAME" "$mysql_con_source" "$mysql_con_target"
else 
    sync_table_contents2 "$DB_NAME" "$TABLE_NAME" "$mysql_con_source" "$mysql_con_target"
fi
        

