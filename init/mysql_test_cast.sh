mysql_con="mysql -pjie0512"
echo "select * from web.test" | eval "$mysql_con"
echo "show create table web.test" | eval "$mysql_con"
echo "show create table web.test \G" | eval "$mysql_con"

#truncate table
echo "truncate table web.test" | eval "$mysql_con"

#delete table
echo "delete from table web.test" | eval "$mysql_con"

# pipestatus
${PIPESTATUS[*]}

# getddl
echo "show create table web.test" | eval "$mysql_con"


CREATE TABLE `test12` (
  `id` int(11) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `name` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='餐饮生态平台-ERP-数据异常监控表'
;

cat abc.sql | S
    awk -v begin_num=9999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] begin_num 
              }
          if(NR>begin_num){print $0} 
        }'
cat abc.sql | awk '{if($0 ~/CREATE TABLE/)'

echo "12|23|11" | awk '{split($0,a,"|"); print a[3],a[2],a[1]}'


conn_loc="mysql -pjie0512"
echo "show create table web.test;" | eval "mysql -NB $conn_loc" | sed -e 's/.*\(create table\)/\1/i' -e 's/\\n/\n/g'

echo "show create table web.test \G;" | eval "mysql -NB $conn_loc" |
   awk -v begin_num=9999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE" array_list[2] 
              }
          if(NR>begin_num){print $0} 
        }'

echo "show create table web.test;" | eval "mysql -NB $conn_loc" |
    tr A-Z a-z |                                                                                                               
    sed  's/\\n/\n/g' |                                                                                                     
    sed    's/[ \t][ \t]*/ /g' |                                                                                               
    sed     's/\(engine\|auto_increment\|default charset\)=/\n\1=/g' 

http://www.cnblogs.com/ggjucheng/archive/2012/11/13/2768485.html

mysqldump --compact --add-locks --disable-keys --extended-insert --no-create-info --lock-tables --quick  $conn_loc web.test

 eval "mysqldump --compact --add-locks --disable-keys --extended-insert --no-create-info --lock-tables \
  --quick --set-charset $MYSQLDUMP_OPTS $mysqldump_extra_clause $conn_loc $table" |
   tee /tmp/lala | pvwrap "$table copy" $total_rows | eval "mysql -C -NB $conn_rem" 2>$TMP.$table.copy_err

export:
mysqldump -uxjc -pjie0512 web test>./a1.sq
import:
conn_loc="-pjie0512"
cat a1.sql  | eval "mysql -NB -Dweb $conn_loc"

plan2:
echo "SELECT * INTO OUTFILE '/home/xjc/git/mysql_sync/mysql_sync_stag/tmp/result2.txt' 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
FROM web.test" | eval "mysql -NB -C $conn_loc"
LOAD DATA LOCAL INFILE '/tmp/result.txt' INTO TABLE test.user
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'

mysqldump -uxjc -pjie0512 web test>./a1.sq | xargs cat ./a1.sql  | eval "mysql -Dweb -pjie0512 -NB -C"