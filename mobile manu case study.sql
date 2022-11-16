--SQL Advance Case Study


--Q1--BEGIN 
select State
from FACT_TRANSACTIONS t
inner join DIM_LOCATION l on t.IDLocation=l.IDLocation
inner join DIM_MODEL m on t.IDModel=m.IDModel
where Date between '01-01-2005' and GETDATE()



--Q1--END

--Q2--BEGIN
select State,SUM(Quantity)as QTY
from DIM_LOCATION l
inner join FACT_TRANSACTIONS t on l.IDLocation=t.IDLocation
inner join DIM_MODEL m on t.IDModel=m.IDModel
inner join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
where Country='US' and  Manufacturer_Name='Samsung'
group by State
order by SUM(Quantity) desc	








--Q2--END

--Q3--BEGIN  
select Model_Name,ZipCode,State,COUNT(IdCustomer) as no_of_tran
from DIM_LOCATION l
inner join FACT_TRANSACTIONS t on l.IDLocation=t.IDLocation
inner join DIM_MODEL m on t.IDModel=m.IDModel
group by Model_Name,ZipCode,State	








--Q3--END

--Q4--BEGIN
select top 1 IdModel,Model_Name,Unit_price
from DIM_MODEL
order by Unit_price asc


--Q4--END

--Q5--BEGIN
select Model_name,AVG(Unit_price)as avg_price
from DIM_MODEL m
inner join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
where Manufacturer_Name in 
(
      select top 5 Manufacturer_Name
      from FACT_TRANSACTIONS t
      inner join DIM_MODEL m on t.IDModel=m.IDModel
      inner join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
      group by Manufacturer_Name
      order by SUM(Quantity)
)
group by Model_Name
order by avg_price desc











--Q5--END

--Q6--BEGIN
select Customer_Name,AVG(TotalPrice) as avg_amt
from DIM_CUSTOMER c
inner join FACT_TRANSACTIONS t on c.IDCustomer=t.IDCustomer
where YEAR(Date)=2009
group by Customer_Name
having AVG(TotalPrice) > 500









--Q6--END
	
--Q7--BEGIN
select * from
(
   select top 5 Manufacturer_Name 
   from FACT_TRANSACTIONS t 
   left join DIM_MODEL m on t.IDModel=m.IDModel
   left join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
   where DATEPART(Year,Date)='2008'
   group by Manufacturer_Name,Quantity
   order by SUM(Quantity) desc
intersect
   select top 5 Manufacturer_Name 
   from FACT_TRANSACTIONS t 
   left join DIM_MODEL m on t.IDModel=m.IDModel
   left join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
   where DATEPART(Year,Date)='2009'
   group by Manufacturer_Name,Quantity
   order by SUM(Quantity) desc
intersect
   select top 5 Manufacturer_Name 
   from FACT_TRANSACTIONS t 
   left join DIM_MODEL m on t.IDModel=m.IDModel
   left join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
   where DATEPART(Year,Date)='2010'
   group by Manufacturer_Name,Quantity
   order by SUM(Quantity) desc
)as A










--Q7--END	
--Q8--BEGIN
with cte as 
(
    select Manufacturer_Name, DATEPART(YEAR, Date) as yr,
    DENSE_RANK() OVER (PARTITION BY DATEPART (YEAR, Date) order by SUM(TotalPrice) desc) as RANK
    from FACT_TRANSACTIONS t
    inner join DIM_MODEL m on t.IDModel=m.IDModel
    inner join DIM_MANUFACTURER f on m.IDManufacturer=f.IDManufacturer
    group by Manufacturer_Name,DATEPART(YEAR,Date)
),
cte2 as
(
    select Manufacturer_Name,yr
    from cte where rank=2
    and yr in ('2009','2010')
)
    select c.Manufacturer_Name as manu_name_2009,
    t.Manufacturer_Name as manu_name_2010
    from cte2 as c , cte2 as t
    where c.yr < t.yr;













--Q8--END
--Q9--BEGIN
Select Manufacturer_Name
from DIM_MANUFACTURER f
inner join DIM_MODEL m on f.IDManufacturer=m.IDManufacturer
inner join FACT_TRANSACTIONS t on m.IDModel=t.IDModel
where YEAR(Date)='2010'

except

Select Manufacturer_Name
from DIM_MANUFACTURER f
inner join DIM_MODEL m on f.IDManufacturer=m.IDManufacturer
inner join FACT_TRANSACTIONS t on m.IDModel=t.IDModel
where YEAR(Date)='2009'	

















--Q9--END

--Q10--BEGIN
select
T1.Customer_Name, T1.Year, T1.Avg_Price, T1. Avg_Qty,
case when T2. YEAR IS NOT NULL 
then FORMAT(CONVERT(DECIMAL(8,2),(T1.Avg_Price-T2.Avg_Price))/CONVERT(DECIMAL(8,2),T2.Avg_Price),'p') else NULL
END as 'yr_%_change'
from
(
select t2.Customer_Name, YEAR(t1.Date) as YEAR, AVG(t1.TotalPrice) as Avg_price, AVG(t1.Quantity) as Avg_Qty
from FACT_TRANSACTIONS as t1
inner join DIM_CUSTOMER t2 on t1.IDCustomer=t2.IDCustomer
where t1.IDCustomer in 
(
select top 100 IdCustomer from FACT_TRANSACTIONS
group by IdCustomer 
order by SUM(TotalPrice) desc)
group by t2.Customer_Name, YEAR(t1.Date)
)T1
inner join
(
select t2.Customer_Name, YEAR(t1.Date) as YEAR, AVG(t1.TotalPrice) as Avg_price, AVG(t1.Quantity) as Avg_Qty
from FACT_TRANSACTIONS as t1
inner join DIM_CUSTOMER t2 on t1.IDCustomer=t2.IDCustomer
where t1.IDCustomer in 
(
select top 100 IdCustomer from FACT_TRANSACTIONS
group by IdCustomer 
order by SUM(TotalPrice) desc)
group by t2.Customer_Name, YEAR(t1.Date)
)T2
on T1.Customer_Name=T2.Customer_Name and T2.YEAR=T1.YEAR-1	


















--Q10--END
	