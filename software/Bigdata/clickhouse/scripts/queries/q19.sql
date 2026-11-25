-- CH 适配版：原版把 p_partkey = l_partkey 写在 OR 的每个分支里，ClickHouse 无法从 OR 中
-- 提取等值连接键，退化成笛卡尔积（SF1 上 10 分钟都跑不完）。改写成三个 UNION ALL 分支，
-- 每个分支一个等值 join。结果等价（三个分支互斥，sum 相加等于整体 sum）。
select sum(revenue) as revenue from (
    select sum(l_extendedprice * (1 - l_discount)) as revenue
    from lineitem join part on p_partkey = l_partkey
    where p_brand = 'Brand#12'
      and p_container in ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')
      and l_quantity >= 1 and l_quantity <= 1 + 10
      and p_size between 1 and 5
      and l_shipmode in ('AIR', 'AIR REG')
      and l_shipinstruct = 'DELIVER IN PERSON'
    union all
    select sum(l_extendedprice * (1 - l_discount))
    from lineitem join part on p_partkey = l_partkey
    where p_brand = 'Brand#23'
      and p_container in ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')
      and l_quantity >= 10 and l_quantity <= 10 + 10
      and p_size between 1 and 10
      and l_shipmode in ('AIR', 'AIR REG')
      and l_shipinstruct = 'DELIVER IN PERSON'
    union all
    select sum(l_extendedprice * (1 - l_discount))
    from lineitem join part on p_partkey = l_partkey
    where p_brand = 'Brand#34'
      and p_container in ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')
      and l_quantity >= 20 and l_quantity <= 20 + 10
      and p_size between 1 and 15
      and l_shipmode in ('AIR', 'AIR REG')
      and l_shipinstruct = 'DELIVER IN PERSON'
);
