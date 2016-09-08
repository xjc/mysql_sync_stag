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

cat abc.sql | 
    awk -v begin_num=9999 '{if($0 ~/CREATE TABLE/) 
              {begin_num=NR; split($0, array_list, "CREATE TABLE"); 
              print "CREATE TABLE " array_list[2] begin_num 
              }
          if(NR>begin_num){print $0} 
        }'
cat abc.sql | awk '{if($0 ~/CREATE TABLE/)

echo "12|23|11" | awk '{split($0,a,"|"); print a[3],a[2],a[1]}'
