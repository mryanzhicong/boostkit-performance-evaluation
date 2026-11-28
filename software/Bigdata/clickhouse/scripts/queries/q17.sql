-- CH 适配版：关联标量子查询改成"按 partkey 预聚合 + join"。语义等价。
with part_avg as (
    select l_partkey as k, 0.2 * avg(l_quantity) as th
    from lineitem
    group by l_partkey
)
select sum(l_extendedprice) / 7.0 as avg_yearly
from lineitem
join part on p_partkey = l_partkey
join part_avg on part_avg.k = l_partkey
where p_brand = 'Brand#23' and p_container = 'MED BOX' and l_quantity < part_avg.th;
