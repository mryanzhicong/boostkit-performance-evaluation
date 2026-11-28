-- CH 适配版：原版 q21 的 EXISTS/NOT EXISTS 关联子查询在 ClickHouse 里要么不支持、要么需要
-- 实验性 join 条件（allow_experimental_join_condition）。这里改写成两步等值 join：
--   1) "存在同订单另一供应商" ⇔ 该订单 distinct 供应商数 > 1（IN 子查询，无关联）
--   2) "不存在同订单另一供应商的晚收货行" ⇔ 该订单的晚收货供应商集合 ⊆ {当前供应商}
--      即 late_cnt 为空，或 late_cnt=1 且唯一那个晚收货供应商就是自己
with late as (
    select l_orderkey as k, uniqExact(l_suppkey) as c, min(l_suppkey) as s
    from lineitem
    where l_receiptdate > l_commitdate
    group by l_orderkey
)
select s_name, count(*) as numwait
from supplier
join nation on s_nationkey = n_nationkey and n_name = 'SAUDI ARABIA'
join lineitem as l1 on l1.l_suppkey = s_suppkey
join orders on o_orderkey = l1.l_orderkey and o_orderstatus = 'F'
left join late on late.k = l1.l_orderkey
where l1.l_receiptdate > l1.l_commitdate
  and l1.l_orderkey in (
      select l_orderkey from lineitem group by l_orderkey having uniqExact(l_suppkey) > 1)
  and (late.c is null or (late.c = 1 and late.s = l1.l_suppkey))
group by s_name
order by numwait desc, s_name
limit 100;
