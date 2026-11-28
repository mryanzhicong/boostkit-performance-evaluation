-- CH 适配版（原版用关联标量子查询，ClickHouse 24.5 不支持 correltaed scalar subquery）
-- 改写：把 min(ps_supplycost) 按 partkey 预聚合为 CTE，再等值 join 回去。语义等价。
with min_cost as (
    select ps_partkey as k, min(ps_supplycost) as msc
    from partsupp
    join supplier on ps_suppkey = s_suppkey
    join nation on s_nationkey = n_nationkey
    join region on n_regionkey = r_regionkey
    where r_name = 'EUROPE'
    group by ps_partkey
)
select s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment
from part
join partsupp on p_partkey = ps_partkey
join supplier on s_suppkey = ps_suppkey
join nation on s_nationkey = n_nationkey
join region on n_regionkey = r_regionkey
join min_cost on min_cost.k = p_partkey and min_cost.msc = ps_supplycost
where p_size = 15 and p_type like '%BRASS' and r_name = 'EUROPE'
order by s_acctbal desc, n_name, s_name, p_partkey
limit 100;
