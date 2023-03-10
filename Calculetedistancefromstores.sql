select t2.store_id,count(distinct ss.user_id) from
(
(select fmr.session_id,fmr.lat,fmr.lng,fmr.timestamp_date,
ROW_NUMBER() OVER (ORDER BY session_id,fmr.lat,fmr.lng,fmr.timestamp_date) as rn
from analytics.find_mall_request as fmr
where fmr.timestamp_date >= '2022-09-01'
and fmr.timestamp_date <= '2022-12-31'
and date_part(hour, fmr.timestamp) in (0, 1, 2, 3, 4, 5, 6)) as t1
cross join
(select p.store_id,p.lat,p.lng,
ROW_NUMBER() OVER (ORDER BY p.store_id,p.lat,p.lng) AS rn
from public.storelist_202301 p
) as t2
)
inner join analytics.session ss on ss.session_id=t1.session_id
where f_great_circle_distance(t1.lat,t1.lng,t2.lng,t2.lat)<=2000
and ss.timestamp_date>='2022-01-01' and ss.timestamp_date<='2022-12-31'
and t2.lat is not null and t2.lng is not null
and len(ss.user_id)=8
group by 1
having count(distinct concat(t1.session_id, t1.timestamp_date)) > 1
