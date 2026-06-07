## create a clean data set
create table hotel_bookings_cleaned as
select 
hotel,
is_canceled,
lead_time,
arrival_date_year,
arrival_date_month,
arrival_date_week_number,
arrival_date_day_of_month,
country,
market_segment,
distribution_channel,
customer_type,
reserved_room_type,
assigned_room_type,
adr,
days_in_waiting_list,
total_of_special_requests,
adults,
children,
babies,
stays_in_week_nights,
stays_in_weekend_nights
from hotel_bookings


## Check Missing Values

UPDATE hotel_bookings_cleaned
SET children = 0
WHERE children IS NULL;

UPDATE hotel_bookings_cleaned
 set babies = 0
 where babies is null
 
 UPDATE hotel_bookings_cleaned
 set country = 'unknown'
 where country is null

SELECT *
FROM hotel_bookings_cleaned
WHERE adults = 0
AND children = 0
AND babies = 0;

DELETE FROM hotel_bookings_cleaned
WHERE adults = 0
AND children = 0
AND babies = 0;

DELETE FROM hotel_bookings_cleaned
WHERE adr < 0;

## create identify
alter table hotel_bookings_cleaned
ADD booking_id INT AUTO_INCREMENT PRIMARY KEY; 
 

# create new column masures
alter table hotel_bookings_cleaned
add column total_guests int

update hotel_bookings_cleaned
set
total_guests = adults + children + babies

alter table hotel_bookings_cleaned
add column total_nights int

update hotel_bookings_cleaned
set
total_nights = stays_in_week_nights + stays_in_weekend_nights

alter table hotel_bookings_cleaned
add column guest_origin varchar (100)

update hotel_bookings_cleaned
set guest_origin = CASE WHEN country = 'PRT' THEN 'Domestic'
ELSE 'International' end

alter table hotel_bookings_cleaned
add column lead_time_category varchar (100)


update hotel_bookings_cleaned
set lead_time_category = CASE WHEN lead_time <= 30 THEN 'Short-Term'
WHEN lead_time <= 90 THEN 'Medium-Term'
ELSE 'Long-Term' end

ALTER TABLE hotel_bookings_cleaned
ADD reassignment_status VARCHAR(20);

UPDATE hotel_bookings_cleaned
SET reassignment_status =
CASE
WHEN reserved_room_type = assigned_room_type
THEN 'Not Reassigned'
ELSE 'Reassigned'
END;

ALTER TABLE hotel_bookings_cleaned
ADD total_revenue DECIMAL(10,2);

update hotel_bookings_cleaned
set total_revenue = adr * total_nights;

ALTER TABLE hotel_bookings_cleaned
ADD family_type varchar (20);

update hotel_bookings_cleaned
set family_type = CASE
WHEN children > 0 OR babies > 0
THEN 'Family'
ELSE 'Non-Family'
END

ALTER TABLE hotel_bookings_cleaned
ADD cancellation_status varchar (20);

update hotel_bookings_cleaned
set cancellation_status = CASE
WHEN is_canceled = 1 THEN 'Canceled'
ELSE 'Not Canceled'
END

## creating dimansional tables

create table date_table as
select 	
arrival_date_year,
arrival_date_month	
 from hotel_bookings_cleaned

alter table date_table
add date_id INT AUTO_INCREMENT PRIMARY KEY; 

create table customer_table as
select 	
country,
guest_origin,
customer_type,
adults,
children,
babies,
total_guests,
family_type
from hotel_bookings_cleaned

alter table customer_table
add cutomer_id INT AUTO_INCREMENT PRIMARY KEY; 

create table room_table as
select 	reserved_room_type,
assigned_room_type,
reassignment_status
from hotel_bookings_cleaned

alter table room_table
add room_id INT AUTO_INCREMENT PRIMARY KEY; 

alter table hotel_bookings_cleaned
add date_id int

alter table hotel_bookings_cleaned
add customer_id int,
add room_id int

update hotel_bookings_cleaned as h
join date_table as d
on h.arrival_date_year= d.arrival_date_year
set h.date_id = d.date_id

update hotel_bookings_cleaned as h
join customer_table as c
on h.country = c.country
and h.customer_type= c.customer_type
and h.adults =c.adults
and h.children = c.children
and h,babies = c.babies
set h.customer_id = c.customer_id

join room_table as r
on h.reserved_room_type = r.reserved_room_type
and h.assigned_room_type = r.assigned_room_type
set h.room_id= r.room_id
