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
