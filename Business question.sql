-- Business question: Wild West wants to determine which business customers have monthly revenue(for a given month) which exceeds the average per-customer revenue of all business customers for that same month. Use January 1999 data for signoff.

-- source table
with buscust as (
    select * from WILDWEST.PROCESSED.buscust
    ,jan_00 as (
        select * from WILDWEST.PROCESSED.BMSG001
    )
    , jan_99 as (
        select * from WILDWEST.PROCESSED.BMSG9901
    )
    ,feb_99 as (
        select * from WILDWEST.PROCESSED.BMSG9902
    )
    ,mar_99 as (
        select * from WILDWEST.PROCESSED.BMSG9903
    )
    ,apr_99 as (
        select * from WILDWEST.PROCESSED.BMSG9904
    )
)

-- total rev 
,revenue_jan_00 as (
    select BILL_AREA_CODE, BILL_EXCHANGE, BILL_LINE, sum(rev_amt) as total_rev from WILDWEST.PROCESSED.BMSG001 group by all
)
,revenue_jan_99 as (
    select BILL_AREA_CODE, BILL_EXCHANGE, BILL_LINE, sum(rev_amt) as total_rev from WILDWEST.PROCESSED.BMSG9901 group by all
)
,revenue_feb_99 as (
    select BILL_AREA_CODE, BILL_EXCHANGE, BILL_LINE, sum(rev_amt) as total_rev from WILDWEST.PROCESSED.BMSG9902 group by all
)
,revenue_mar_99 as (
    select BILL_AREA_CODE, BILL_EXCHANGE, BILL_LINE, sum(rev_amt) as total_rev from WILDWEST.PROCESSED.BMSG9903 group by all
)
,revenue_apr_99 as (
    select BILL_AREA_CODE, BILL_EXCHANGE, BILL_LINE, sum(rev_amt) as total_rev from WILDWEST.PROCESSED.BMSG9904 group by all
)

-- calculate the average amount per month 
, avg_jan_00 as (
select avg(total_rev) from revenue_jan_00
)
, avg_jan_99 as (
select avg(total_rev) from revenue_jan_99
)
, avg_feb_99 as (
select avg(total_rev) from revenue_feb_99
)
, avg_mar_99 as (
select avg(total_rev) from revenue_mar_99
)
, avg_apr_99 as (
select avg(total_rev) from revenue_apr_99
)

-- join table
, maintable as (
select *
from buscust b
join revenue_jan_99 rev99
on b.BILL_AREA_CODE = rev99.BILL_AREA_CODE
and b.LINE = rev99.BILL_LINE
and b.EXCHANGE = rev99.BILL_EXCHANGE
)

,final_table as (
select cust_id, name, city, total_rev
from maintable
where total_rev > (select avg(total_rev) from_jan_99)
)
select * from final_table
