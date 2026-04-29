 -- =======================================================================================================================================================
-- PROJECT: PROJECT: UBER DATA ANALYSIS CASE STUDY
-- TOOLS USED: MYSQL 
 -- =====================================================================================================================================================
 
 -- ----------------------------------------------------------------------------------------------------------------------------------------------------------
 -- DATABASE CREATION.
create database uber;
use sandhya_uber;

 -- TABLE CREATION
create table drivers(
driver_id int primary key,
driver_name varchar(50),
join_date date,
rating decimal(3,2),
total_rides int,
earnings decimal(10,2));


create table passangers(
passenger_id int primary key,
passenger_name varchar(50),
signup_date date,
total_rides int,
total_spent decimal(10,2),
rating decimal(5,2));


create table rides(
ride_id int primary key,
driver_id int,
passenger_id int,
pickup_location varchar(50),
dropoff_location varchar(50),
ride_distance DECIMAL(5,2),
ride_duration int COMMENT 'duration in minutes',
ride_timestamp datetime,
fare_amount DECIMAL(10,2),
payment_method varchar(20));

select* from drivers;
select* from passangers;
select* from rides;
 -- ========================================================================================================================================================
 -- QUERIES.

-- 1. What are & how many unique pickup locations are there in the dataset?

select count(distinct pickup_location) as total_unique_location from rides;

-- 2. What is the total number of rides in the dataset?

select count(ride_id) as total_number_rides from rides;

-- 3. Calculate the average ride duration.

select avg(ride_duration) as avg_ride_duration from rides;

-- 4. List the top 5 drivers based on their total earnings.

select round(sum(fare_amount),2 ) as total_earning from rides
group by driver_id 
order by total_earning desc limit 5;

-- 5. Calculate the total number of rides for each payment method.

select payment_method, count(ride_id) as total_number_rides from rides group by payment_method;

-- 6. Retrieve rides with a fare amount greater than 20.

select * from rides where fare_amount > 20;

-- 7. Identify the most common pickup location.

select pickup_location, count(*) as total_rides from rides
group by pickup_location 
order by total_rides desc limit 1; 

-- 8. Calculate the average fare amount.

select avg(fare_amount) as avg_fare_amount from rides;

-- 9. List the top 10 drivers with the highest average ratings.

select driver_id, rating, driver_name from drivers
order by rating desc limit 10; 

-- 10. Calculate the total earnings for all drivers.

select round(sum(earnings),2) as total_earning from drivers;

-- 11. How many rides were paid using the "Cash" payment method

select count(*) as total_cash_Rides from rides where payment_method = 'cash';

 -- 12. Calculate the number of rides & average ride distance for rides originating from the 'Dhanbad' pickup location.
 
select count(*) as numberof_total_rides, round(avg(ride_distance),2) as avg_ride_distance from rides
where pickup_location = 'Dhanbad';

-- 13. Retrieve rides with a ride duration less than 10 minutes.

 -- METHOD 1
select * from  rides where ride_duration < 10;

 -- METHOD 2
select pickup_location, ride_distance,ride_duration  from rides where ride_duration < 10;

 -- METHOD 3
select pickup_location, ride_distance,ride_duration  from rides where ride_duration < 10 order by ride_duration asc;

 -- 14. List the passengers who have taken the most number of rides.
 
 select passenger_id, count(*) as most_number_rides from rides 
 group by passenger_id 
 order by most_number_rides desc limit 1;
 

-- 15. Calculate the total number of rides for each driver in descending order.

select driver_id, count(driver_id) as total_number_rides from rides 
group by driver_id 
order by total_number_rides desc;

-- 16. Identify the payment methods used by passengers who took rides from the 'Gandhinagar' pickup location.

select distinct passenger_id, payment_method, pickup_location from rides 
where pickup_location = 'Gandhinagar';

-- 17. Calculate the average fare amount for rides with a ride distance greater than 10.

select round(avg(fare_amount),2) as avg_fare_amount from rides where ride_distance >10;

-- 18. List the drivers in descending order accordinh to their total number of rides.

select driver_id, count(*) as total_number_rides from rides 
group by driver_id order by total_number_rides desc;

 -- Method 2
select driver_id, total_rides from drivers order by total_rides desc;

-- 19. Calculate the percentage distribution of rides for each pickup location.

select pickup_location, 
count(*) as total_rides, 
concat(round((count(*) * 100.0) / (select count(*) from rides), 2), '%') as percentage
from rides
group by pickup_location
order by total_rides;


-- 20. Retrieve rides where both pickup and dropoff locations are the same.

select ride_id, pickup_location, dropoff_location from rides
where pickup_location = dropoff_location;


-- 21. List the passengers who have taken rides from at least 300 different pickup locations.

select p.passenger_id, p.passenger_name,  count(distinct  r.pickup_location) as unique_pickup_location
from rides as r inner join passangers as p 
on r.passenger_id = p.passenger_id
group by p.passenger_id, p.passenger_name
having count(distinct  r.pickup_location) >=300;

-- 22. Calculate the average fare amount for rides taken on weekdays.--

alter table rides
add column  new_ride_date date;

set sql_safe_updates = 0;

update rides
set new_ride_date = str_to_date(ride_timestamp, '%d-%m-%y');

set sql_safe_updates = 1;
select ride_timestamp, new_ride_date, dayname(new_ride_date)
from rides
limit 10;

select count(*)
from rides
where new_ride_date is not null;

select count(*)
from rides
where dayname(new_ride_date) not in ('saturday','sunday');

select round(avg(fare_amount),2) as avg_fare_weekday_fare
from rides
where dayname(new_ride_date) not in ('saturday','sunday');

 -- 23. Identify the drivers who have taken rides with distances greater than 19.
 
 -- METHO 1
select distinct driver_id, ride_distance  from rides where ride_distance  >19;

 -- -- METHO 2
select r.driver_id, d.driver_name, r.ride_distance from rides as r inner join drivers as d
on r.driver_id = d.driver_id
where r.ride_distance  >19;

-- 24. Calculate the total earnings for drivers who have completed more than 100 rides.

 -- METHOD 1
select driver_id, driver_name, earnings from drivers  where total_rides  > 100;

 -- -- METHOD 2
select driver_id, driver_name, sum(earnings) as total_earning from drivers
 where total_rides  > 100
 group by driver_id, driver_name;
 
 
-- 25. Retrieve rides where the fare amount is less than the average fare amount.

select * from rides where fare_amount < (select avg(fare_amount) from rides); 

  
-- 26. Calculate the average rating of drivers who have driven rides with both 'Credit Card' and 'Cash' payment methods.

select round(avg(d.rating),2) as avg_driver_rating
from drivers d
where d.driver_id in (
    select driver_id
    from rides
    where payment_method in ('credit card','cash')
    group by driver_id
    having count(distinct payment_method) = 2);

 -- 27. List the top 3 passengers with the highest total spending.
 
select  passenger_id, passenger_name, total_spent from passangers
 order by total_spent  desc limit 3;

 -- 28. Calculate the average fare amount for rides taken during different months of the year.
 
  -- METHOD 1
select monthname(new_ride_date) as month, 
round(avg(fare_amount),2) as avg_fare_amount from rides
group by month(new_ride_date), monthname(new_ride_date)
order by month(new_ride_date);

  -- METHOD 2
select year(new_ride_date),month(new_ride_date),avg(fare_amount) from rides
group by month(new_ride_date),year(new_ride_date);


-- 29. Identify the most common pair of pickup and dropoff locations.

select pickup_location, dropoff_location, count(*) from rides
group by pickup_location, dropoff_location
order by count(*) desc;

-- 30. Calculate the total earnings for each driver and order them by earnings in descending order.

 -- METHOD 1
select driver_id, driver_name, earnings as total_earning from drivers order by earnings desc;

 -- METHOD 2
select driver_name,earnings from drivers
order by earnings desc;

 -- ######################################################################################################################################################################################################3

