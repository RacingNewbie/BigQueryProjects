/*
>>>This project analyzes a nationwide used-car portfolio dataset to uncover key business insights for strategic decision-making. 
Using BigQuery SQL with:-
1.chained CTEs
2.aggregations
3.regex segmentation
4.window functions
>>>The analysis identifies:-
1.The best-performing and most frequently purchased vehicle brands
2.Evaluates brand-wise profitability based on total revenue contribution
3.Segments manufacturers into business-relevant car leagues such as 
a.American
b.German
c.JDM
to determine which sector dominates the market. It further highlights high-demand vs low-demand vehicle segments to support inventory and market positioning strategies, flags major declining brands by state volume to aid regional market planning, and compares selling prices against category averages to identify value-retaining or overpriced listings. 

The key goal is to pinpoint the highest-selling, revenue-driving brands, determine the most profitable and declining car segments across states, and showcase how purchasing behavior and revenue potential vary across manufacturer leagues — providing a strong analytical foundation for dashboards, regional sales reports, and future business expansion plans.


*/

#Which cars contribute to the most profits
with Profitable_Cars as (SELECT brand,
sum(price) as total_price,
count(brand) as Number_Of_Cars,
round(avg(price),2) as average_price
FROM `effective-light-477218-f8.Newdataset.USACarDataset` 
GROUP BY brand
ORDER BY total_price DESC
)
select * from Profitable_Cars where total_price > 1000000
order by total_price desc;

#Which vehicle correspond to the least sales this month?
with lossful_vehicles as (
select brand,sum(price) as total_price,count(brand) as total_cars,round(avg(price),0) as AveragePrice
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by brand
having count(brand)<=20
order by total_cars asc
)
select * from lossful_vehicles;
#Which cars have selling price higher than their average prices
with avg_better as (
  select brand,count(brand) as total,
  round(avg(price),0) as avg_p
  from `effective-light-477218-f8.Newdataset.USACarDataset` 
  group by brand
)
select ab.brand,ab.avg_p as avg_price,
p1.price as price,
case when
p1.price>=avg_p then 'better'
else 'worse'
end as better_or_worse
from avg_better ab
join `effective-light-477218-f8.Newdataset.USACarDataset` p1
on ab.brand=p1.brand
where p1.title_status = 'clean vehicle'
order by p1.price desc;

select distinct(country) from `effective-light-477218-f8.Newdataset.USACarDataset`;

select count(brand) as total_cars,country 
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by country
order by count(brand) desc;

select * 
from `effective-light-477218-f8.Newdataset.USACarDataset` 
where country like 'u%';

#average mileage of each car, divided by city

with mileage_based as (
  select brand,round(avg(mileage),0) as avg_mileage
  from `effective-light-477218-f8.Newdataset.USACarDataset`
  group by brand
  order by sum(mileage) desc
)
,price_based as (
  select brand,round(avg(price),0) as avg_price
  from `effective-light-477218-f8.Newdataset.USACarDataset`
  group by brand
  order by avg(price) desc
)
select pb.brand,pb.avg_price,mb.avg_mileage
from price_based pb
join mileage_based mb
on mb.brand = pb.brand
where mb.avg_mileage>25000 
and pb.avg_price>10000
order by pb.avg_price desc
limit 10;

#Which brands offer the best customer value (low price + low mileage)?
with low_mileage as (
  select brand,min(mileage) as min_mil,
  case
  when min(mileage) < 10000 then 'low'
  when min(mileage) = 10000 then 'mid'
  else 'high'
  end as mil_verdict
  from `effective-light-477218-f8.Newdataset.USACarDataset`
  group by brand
  order by min(mileage) desc
)
,low_cost as (
  select brand,min(price) as min_cost,
  case
  when min(price) < 18000 then 'low'
  when min(price) = 18000 then 'mid'
  else 'high'
  end as cost_verdict
  from `effective-light-477218-f8.Newdataset.USACarDataset`
  group by brand
  order by min(price) asc
)
select lc.brand,lc.min_cost,lm.min_mil
from low_cost lc
join low_mileage lm
on lc.brand = lm.brand
where lc.min_cost > 10000
order by lc.min_cost asc,lm.min_mil asc
;
select distinct(model) from `effective-light-477218-f8.Newdataset.USACarDataset`;

#Top performing US-based vehicles
with brand_rank as (
select b.brand,b.model,a.mileage,a.price
from `effective-light-477218-f8.Newdataset.USACarDataset` a
join `effective-light-477218-f8.Newdataset.USACarDataset` b
on a.brand = b.brand
where regexp_contains(b.brand,'ford|dodge|chevrolet|gmc|jeep|chrysler|buick|ram|pontiac')
order by a.mileage DESC,a.price desc
)
select brand,count(brand) as Number_of_Vehicles,
round(max(mileage),3) as Max_Mileage,
round(max(price),2) as Max_Price
from brand_rank 
group by brand
order by count(brand) desc,round(avg(price),2) desc,round(avg(mileage),3) desc
;

select distinct(brand) from `effective-light-477218-f8.Newdataset.USACarDataset`;

#Which car league produces the most sold, and satisfied vehicle buyers?
#eg,american,german,JDM
with car_maker as (
  select brand,mileage,price,title_status,year,state,
  case 
  when regexp_contains(brand,'ford|dodge|chevrolet|gmc|jeep|chrysler|buick|ram|pontiac') then 'american'
  when regexp_contains(brand,'(?i)volkswagen|audi|bmw|mercedes-benz') then 'german'
  when regexp_contains(brand,'acura|infiniti|lexus|honda|nissan|toyota|mazda|mitsubishi|subaru|suzuki') then 'JDM'
  when regexp_contains(brand,'jaguar') then 'british'
  when regexp_contains(brand,'kia|hyundai') then 'south korean'
  else 'others'
  end as car_league
from `effective-light-477218-f8.Newdataset.USACarDataset`
)
select brand,max(mileage) as maximum_mileage,max(price) as maximum_price,count(brand) as number_of_cars_sold,car_league
from car_maker
group by brand,car_league
order by count(brand) desc,
max(mileage) desc;
#Top 25 vehicles with the highest average mileage with respect to other years
with yearwise_mileage as 
(
select brand,sum(mileage) as total_mileage,round(avg(mileage),0) as avg_mileage,year
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by year,brand
order by sum(mileage) desc
)
select brand,avg_mileage,year
from yearwise_mileage
order by avg_mileage desc,year desc
limit 25
;
#Most sold vs least sold car models
with top_3 as 
(
  select brand,count(model) as number_of_cars_sold
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by brand
order by count(model) desc
limit 3
)
,bottom_3 as (
  select brand,count(model) as number_of_cars_sold
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by brand
order by count(model) asc
limit 3
)
select * from top_3
union all
select * from bottom_3;
#dominant brand per state
with profitable_brands as 
(
select brand, count(brand) as total_number_of_cars,state
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by state,brand
order by count(brand) desc,state asc,brand asc
)
select * from profitable_brands
order by state asc,total_number_of_cars desc
;
#Year-year sales trend/growth

select distinct(year) as year, round(avg(price),0) as average_price
from `effective-light-477218-f8.Newdataset.USACarDataset`
group by year
having avg(price)>1000
order by year;
#why there was a high price? because these sold only one car, in each year.
select brand,model,year,count(brand) as total_cars from `effective-light-477218-f8.Newdataset.USACarDataset`
where year<1990
group by year,brand,model
order by year desc,total_cars desc;
#ranking with respect to mileage offered each year
with mileage_rank as
(
select brand,year,mileage
from `effective-light-477218-f8.Newdataset.USACarDataset`
)
select *,dense_rank() over (partition by year order by mileage desc) as mileage_rank
from mileage_rank
order by year
;
#percentile based mileage account
select brand,mileage,
percentile_cont(mileage,0.25) over (partition by brand) as quarter_mileage,
percentile_cont(mileage,0.5) over (partition by brand) as median_mileage,
percentile_cont(mileage,0.75) over (partition by brand) as three_fourth_mileage,
ntile(4) over (order by mileage desc) as quantile_position
from `effective-light-477218-f8.Newdataset.USACarDataset`
order by brand,mileage desc;
#quantile_based rank position for the best,good,normal ok and abysmmal cars
with vehicle_choice as
(
select brand,count(brand) as number_of_cars_sold,price,title_status,
case 
when (price<percentile_cont(price,0.5) over()) and(title_status='clean vehicle') then 'Great Choice'
when (price<percentile_cont(price,0.5) over()) or (title_status='clean vehicle') then 'Normal Choice'
when (price<percentile_cont(price,0.75) over()) and (title_status='clean vehicle') then 'Good Choice'
when (price<percentile_cont(price,0.75) over()) or (title_status ='clean vehicle') then 'Ok Choice'
else 'Abysmmal Choice'
end as rank_position,
case 
when regexp_contains(brand,'ford|dodge|chevrolet|gmc|jeep|chrysler|buick|ram|pontiac') then 'American'
when regexp_contains(brand,'(?i)volkswagen|audi|bmw|mercedes-benz') then 'German'
when regexp_contains(brand,'acura|infiniti|lexus|honda|nissan|toyota|mazda|mitsubishi|subaru|suzuki') then 'JDM'
when regexp_contains(brand,'jaguar') then 'British'
when regexp_contains(brand,'kia|hyundai') then 'South Korean'
else 'Others'
end as car_league
from `effective-light-477218-f8.Newdataset.USACarDataset`
where title_status = 'clean vehicle'
group by brand,price,title_status
order by count(brand) desc,price desc
)
select * from vehicle_choice
where rank_position = 'Great Choice';

#to find the outliers, best possible try to use percentile_cont() to enable a view of values beyond the limit

WITH outlier_price AS (
  SELECT brand,model, price
  FROM `effective-light-477218-f8.Newdataset.USACarDataset`
  GROUP BY brand,model, price
  ORDER BY price DESC
),
percentile_p80 AS (
  SELECT DISTINCT
    PERCENTILE_CONT(price, 0.80) OVER() AS price_80_percentile
  FROM `effective-light-477218-f8.Newdataset.USACarDataset`
)
SELECT o.*
FROM outlier_price o
CROSS JOIN percentile_p80 p
WHERE o.price > p.price_80_percentile
ORDER BY o.price DESC;




















