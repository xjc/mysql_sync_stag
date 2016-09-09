use web;
CREATE TABLE `web.table` (
    `datekey` varchar(20) DEFAULT NULL COMMENT '日期(20160701)',
    `date_type` varchar(20) DEFAULT NULL COMMENT '日期类型(20160701)',
    `tenant_id` int(11) NOT NULL COMMENT '租户ID',
    `poi_id` int(11) NOT NULL COMMENT '门店ID',
    `is_order_cnt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '订单数监控（0-非异常/1-异常）',
    `is_order_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '订单金额监控（0-非异常/1-异常）',
    `is_receivable_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '应收金额监控（0-非异常/1-异常）', 
    `is_pay_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '实收金额监控（0-非异常/1-异常）',
    `is_odd_ok` int(11) NOT NULL DEFAULT 0 COMMENT '抹零监控（0-非异常/1-异常）',
    `is_sku_cnt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '商品售卖数量监控（0-非异常/1-异常）',
    `is_sku_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '商品售卖金额监控（0-非异常/1-异常）',
    `is_pay_type_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '支付方式金额监控（0-非异常/1-异常）',
    `is_hour_receivable_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '分时售卖应收金额监控（0-非异常/1-异常）',
    `is_hour_pay_amt_ok` int(11) NOT NULL DEFAULT 0 COMMENT '分时售卖实收金额监控（0-非异常/1-异常）',
    `created_time` datetime DEFAULT NULL COMMENT '创建时间',
    `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
    PRIMARY KEY (`datekey`, `date_type`, `tenant_id`, `poi_id`)
) ENGINE=Innodb DEFAULT CHARSET=utf8 COMMENT='餐饮生态平台-ERP-数据异常监控表'
;

        if [[ $STRUCT_CHECK_ONLY -eq 1 ]]; then 
            record_log "check_only option given, and won't sync the table structure"
        else 
            sync_table_structure $@
            if [[ $LIMIT_ROWS -eq 0 ]]; then
                sync_table_contents $@
            else:
                sync_table_contents2 $@
            fi  
        fi 

select id, age, name INTO OUTFILE "/home/xjc/git/mysql_sync/mysql_sync_stag/mysql_sync_tmp_scripts//web.test.content"
    FIELDS TERMINATED BY ',' 

    LINES TERMINATED BY '\n'
    from web.test

        OPTIONALLY ENCLOSED BY '\"' 

truncate table web.test;
insert into web.test values(1,1,"1");
insert into web.test values(2,2,"2");
insert into web.test values(3,3,"3");
insert into web.test values(4,4,"4");

select * from web.test;