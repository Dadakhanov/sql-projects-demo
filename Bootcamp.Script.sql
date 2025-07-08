--Connecting to DWH
--host = xxx.xxx.xx.xxx
--port = xxxx
--database = bootcamp
--user: student
--password: xxx-xxx-xxx-xxx

--Table: bootcamp_schema.order_table;

--Find answers to the following questions:
--1. Find total number of orders for TOP-3 platforms that Retail Market's customers used.
--2. Find the branch which has the highest rating among TOP-5 branches by orders.
--3. Calculate delayed delivery as a percentage of the total delivery for TOP-10 branches by orders.
--4. Identify which time of the day Retail Market is loosing profit the most: morning (5:00-10:59) afternoon (11:00-16:59) evening (17:00-00:59).

--Columns description:
--order_number – Unique order identifier.
--branch – The branch from which the delivery is made.
--platform – The platform from which the order was placed (iOS, Android, Windows, etc.).
--order_rating – Customer's order rating (0-5).
--order_status – Order status (e.g., "Delivered").
--order_creation_date – Date the order was created.
--order_creation_time – Time the order was created.
--order_acceptance_time – Time the order was accepted.
--delivery_type – Type of delivery (e.g., "Scheduled").
--specified_delivery_date – Scheduled delivery date.
--specified_delivery_time – Scheduled delivery time.
--actual_delivery_time – Actual delivery time.
--delay_minutes – Difference in minutes between the scheduled and actual delivery time (can be negative if delivered early).
--payment_status – Payment status (e.g., "Paid").
--payment_method – Payment method (e.g., "Online card", "Cash").
--card_type – Card type (Visa, MasterCard, Uzcard, etc.).
--goods_cost_after_formation – Cost of goods after order finalization.
--receipt_total_amount – Total amount on the receipt.
--min_delivery_cost – Minimum delivery cost.
--stripe_payment – Payment via Stripe (0 if not used).
--octo_payment – Payment via Octo (0 if not used).
--total_card_payment – Total amount paid by card.
--receipt_loading_time – Receipt loading time.
--collector_id – Order collector's identifier.
--deliveryman_id – Deliveryman's identifier.
--client_number – Client identifier (can be an encrypted phone number).
--delivery_district – Delivery district.
--delivery_address_number – Delivery address number.

SELECT * FROM order_table
LIMIT 10;

--Find total number of orders for TOP-3 platforms that Retail Market's customers used.
WITH top AS (
	SELECT platform, COUNT(order_number) AS order_count
	FROM order_table
	GROUP BY platform 
	ORDER BY order_count DESC
	LIMIT 3
	)
SELECT SUM(order_count) FROM top;


--Find the branch which has the highest rating among TOP-5 branches by orders.
WITH top AS (
	SELECT
		branch,
		COUNT(order_number) AS order_count,
		ROUND(AVG(NULLIF(order_rating, 0)), 2) AS average_rating
	FROM order_table
	GROUP BY branch 
	ORDER BY order_count DESC 
	LIMIT 5
	)
SELECT branch FROM top
ORDER BY average_rating DESC 
LIMIT 1;


--Calculate delayed delivery as a percentage of the total delivery for TOP-10 branches by orders.
WITH delay_table AS (
	SELECT 
		branch,
		COUNT(order_number) AS order_count,
		COUNT(CASE WHEN delay_minutes > 0 THEN 1 END) AS delay_count,
		COUNT(CASE WHEN delay_minutes <= 0 THEN 1 END) AS intime_count,
		(COUNT(CASE WHEN delay_minutes > 0 THEN 1 END) + COUNT(CASE WHEN delay_minutes <= 0 THEN 1 END)) AS total_count
	FROM order_table
	GROUP BY branch
	ORDER BY order_count DESC
	LIMIT 10
	)
SELECT
	branch,
	order_count,
	CONCAT((delay_count * 100 / total_count), '%') AS percentage_delay
FROM delay_table;


--Identify which time of the day Retail Market is loosing profit the most: morning (5:00-10:59) afternoon (11:00-16:59) evening (17:00-00:59).
with cte as (
	select
		goods_cost_after_formation,		
		cast(replace(receipt_total_amount, ',', '.' ) as numeric) as receipt_total_amount_numeric,
		actual_delivery_time
	from
		order_table
	),
	profits as (
	select
		goods_cost_after_formation,
		receipt_total_amount_numeric,
		goods_cost_after_formation - receipt_total_amount_numeric as profit,
		actual_delivery_time,
		extract(hour from actual_delivery_time) as hour,
		case 
			when extract(hour from actual_delivery_time) between 5 and 10 then 'morning'
			when extract(hour from actual_delivery_time) between 11 and 16 then 'afternoon'
			when extract(hour from actual_delivery_time) >= 17 or extract(hour from actual_delivery_time) <= 0 then 'evening'
		end as time_of_day	
	from cte
	)
select
	time_of_day,	
	round(sum(profit), 0) as loss
from 
	profits
where 
	profit < 0
group by 
	time_of_day;




