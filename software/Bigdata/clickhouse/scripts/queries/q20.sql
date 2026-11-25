-- CH 适配版：两层关联子查询改成 CTE 预聚合 + join。语义等价。
with half_qty as (
    select l_partkey as k1, l_suppkey as k2, 0.5 * sum(l_quantity) as half
    from lineitem
    where l_shipdate >= date '1994-01-01'
      and l_shipdate < date '1994-01-01' + interval '1' year
    group by l_partkey, l_suppkey
)
select s_name, s_address
from supplier
join nation on s_nationkey = n_nationkey
where n_name = 'CANADA'
  and s_suppkey in (
    select ps_suppkey
    from partsupp
    join half_qty on half_qty.k1 = ps_partkey and half_qty.k2 = ps_suppkey
    where ps_availqty > half_qty.half
      and ps_partkey in (select p_partkey from part where p_name like 'forest%')
  )
order by s_name;
