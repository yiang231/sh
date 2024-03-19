#!/bin/bash
source /home/oracle/.bash_profile
ouputFile="/oracle/EPMS_0211001_$(date +'%Y%m%d').txt"
epmsBatch=`sqlplus -s /nolog <<END
conn IRA/Aa_11111@22.188.85.109:1521/oraIRA
set pages 0 lin 120 head off
set echo off
set feedback off
SELECT
    TO_CHAR(SYSDATE, 'yyyy-mm-dd hh24:mi:ss') || '|' || -- 1、【必填】采集时间（pollTime）（统计间隔为[polling_time - INTERVAL, polling_time]）
    COUNT(*) || '|' || -- 2、总交易量（txnTotalVol）（00:00:00到 polling_time的总交易量）
    COUNT(CODE) || '|' || -- 3、总交易成功量（txnTotalVolSuc）（00:00:00到 polling_time的成功交易量）
    COUNT(CASE WHEN GXRQ >= SYSDATE - INTERVAL '4' MINUTE and GXRQ < SYSDATE - INTERVAL '1' MINUTE THEN 1 END) || '|' || -- 4、【必填】间隔时间内的交易量（txnVol）（[polling_time - INTERVAL, polling_time] 的交易量）
    COUNT(CASE WHEN GXRQ >= SYSDATE - INTERVAL '4' MINUTE and GXRQ < SYSDATE - INTERVAL '1' MINUTE THEN CODE END) || '|' || -- 5、【必填】间隔时间内的交易成功量（txnVolSuc）（[polling_time - INTERVAL, polling_time] 的成功交易量）
    nvl(TO_CHAR(ROUND(COUNT(CASE WHEN GXRQ >= SYSDATE - INTERVAL '4' MINUTE and GXRQ < SYSDATE - INTERVAL '1' MINUTE THEN CODE END)
                          / NULLIF(COUNT(CASE WHEN GXRQ >= SYSDATE - INTERVAL '4' MINUTE and GXRQ < SYSDATE - INTERVAL '1' MINUTE THEN 1 END), 0), 2), 'fm9999999999990.00'),'1.00') || '|' || -- 6、【必填】间隔时间内的交易成功率（保留两位小数）（txnRatioSuc）（[polling_time - INTERVAL, polling_time]内的交易成功率）
    ROUND(AVG(CASE WHEN XYSJ IS NOT NULL and GXRQ >= SYSDATE - INTERVAL '4' MINUTE and GXRQ < SYSDATE - INTERVAL '1' MINUTE THEN 1 END)) -- 7、【必填】平均交易响应时间（毫秒）（txnRespTime）（[polling_time - INTERVAL, polling_time]内的平均交易响应时间）
        || '|' || 'NULL' -- 8、总交易金额（txnTotalAmount）（00:00:00到 polling_time的总交易金额）
        || '|' || 'NULL' -- 9、间隔时间内的交易金额（txnAmount）（[polling_time - INTERVAL, polling_time] 的交易金额）
        || '|' || 'NULL' -- 10、交易渠道（txnChannel）
        || '|' || 'NULL' -- 11、交易机构（txnType）
        || '|' || '0211001' -- 12、交易码/交易类型（txncode）
        || '|' || 'NULL' -- 13、每秒事务数（tps）
        || '|' || 'NULL' -- 14、扩展字段1
        || '|' || 'NULL' -- 15、扩展字段2
        || '|' || 'NULL' -- 16、扩展字段3
        || '|' || 'NULL' -- 17、扩展字段4
FROM
    RSB0211001
WHERE
    -- 正常例子：23:57:01 -- 00:00:01
    -- 极端例子：23:58:01 -- 00:01:01
    -- 极端例子：23:59:01 -- 00:02:01
    -- 问题一：数据丢失
    -- 问题二：日志文件错位
    GXRQ >= TRUNC(SYSDATE)
GROUP BY
    TRUNC(SYSDATE)
;
exit;
END`
echo "$epmsBatch" >> "$ouputFile"
ftp -n<<EOF
open 22.187.25.82
user epmsftp Aa-33333#
binary
cd /dip/JJLSH
lcd /oracle
prompt off
mput EPMS_0211001_*.txt
close
quit
EOF
rm -f /oracle/EPMS_0211001_$(date -d '-1 day' +'%Y%m%d').txt