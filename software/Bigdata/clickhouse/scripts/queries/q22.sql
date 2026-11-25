-- CH 适配版：关联 NOT EXISTS 改成 LEFT ANTI JOIN。语义等价。
select cntrycode, count(*) as numcust, sum(c_acctbal) as totacctbal
from (
    select substring(c_phone, 1, 2) as cntrycode, c_acctbal
    from customer
    left anti join orders on o_custkey = c_custkey
    where substring(c_phone, 1, 2) in ('13', '31', '23', '29', '30', '18', '17')
      and c_acctbal > (
        select avg(c_acctbal) from customer
        where c_acctbal > 0
          and substring(c_phone, 1, 2) in ('13', '31', '23', '29', '30', '18', '17'))
) as custsale
group by cntrycode
order by cntrycode;
