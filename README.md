# mysql_sync_stag
sync data between two mysql servers

使用须知：
   使用前先配置下 mysql_con_source， mysql_con_target  

******
```
Usage: ./mysql_sync_test.sh -d DB_NAME -t TABLE_NAME -c STRUCT_CHECK_ONLY(1|0,default 0) -n LIMIT_ROWS(default 0)
       ./mysql_sync_test.sh -d DB_NAME -t TABLE_NAME -c 1   #only check the table structure
       ./mysql_sync_test.sh -d DB_NAME -t TABLE_NAME -n 1000  #sync the table structure and only sync 1000 rows
PARAMETERS: 
            STRUCT_CHECK_ONLY: default 0, 1:check only|0:check first and sync the table
            LIMIT_ROWS         default 0, 0:sync all the table data | n(n>0) sync n rows
eg: ./mysql_sync_test.sh -d web -t test -c 1    #only check the table struct
    ./mysql_sync_test.sh -d web -t test   #sync the table struct and table content
    ./mysql_sync_test.sh -d web -t test -n 100   #sync the table struct and sync 100 rows
```
