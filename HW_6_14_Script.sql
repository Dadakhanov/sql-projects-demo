--Задание №1. Вывести из course_schema.employees всех сотрудников,
--которые занимают 2 ранг по зарплате (сортировка по убыванию) в своем отделе.
--Подсказка (здесь придется использовать как оконные функции, так и вложенные запросы или CTE).

with table_cte as 
(
select
		department,
		first_name,
		last_name,
		salary,
		dense_rank () over (partition by department order by salary desc) as dense_rank_num
from
		employees
)
select * from table_cte
where dense_rank_num = 2;

--Задание №2. Из таблицы course_schema.flight_detail вывести по каждой авиакомпании
--самый первый рейс, которые она совершила (сортировка по departure time).

with ranked_flights as 
(
select
		aircompany_id,
		flight_number,
		origin,
		destination,
		departure_time,
		row_number () over (partition by aircompany_id order by departure_time) as first_flight
from
		flight_detail
)
select
		aircompany_id,
		flight_number,
		origin,
		destination,
		departure_time
from
		ranked_flights
where
		first_flight = 1;