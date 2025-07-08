--Задание 1. Используйте таблицу flight_detail из схемы course_schema.
--Постройте запрос, который рассчитывает скользящее среднее количество пассажиров
--(moving_avg_pax) за последние 3 рейса (включая текущий)
--Подсказка, здесь нужно будет задать оконный фрейм
select
		flight_number,
		departure_time,
		passengers,
		round(avg(passengers) over (order by departure_time rows between 2 preceding and current row), 0) as moving_avg_pax
from flight_detail;

--Задание 2. Используйте таблицы flight_detail и aircompany_detail.
--Создайте запрос, который ранжирует авиакомпании по общему количеству
--перевезенных пассажиров.
--Включите в запрос вывод ранга (company_rank) и названия авиакомпании
--(aircompany_name).
--Попробуйте сделать это упражнение с
--1. Вложенным запросом или CTE
with table_cte as (
					select
							ad.aircompany_name,
							sum(fd.passengers) as total_passengers,
							rank () over (order by sum(fd.passengers) desc) as company_rank
					from
							aircompany_detail ad
							join flight_detail fd on
							ad.aircompany_id = fd.aircompany_id
					group by
							ad.aircompany_name
					)
select
		aircompany_name,
		company_rank
from
		table_cte;
--2. Одним скриптом, без вложенных конструкций
select
		ad.aircompany_name,
		sum(fd.passengers) as total_passengers,
		rank () over (order by sum(fd.passengers) desc) as company_rank
from
		aircompany_detail ad
		join flight_detail fd on
		ad.aircompany_id = fd.aircompany_id
group by
		ad.aircompany_name;

--Задание 3. Есть таблица сотрудников course_schema.employees . Напишите запрос,
--который для каждого сотрудника выводить:
-- сколько человек трудится в его отделе ( emp_cnt );
-- какая средняя зарплата по отделу ( sal_avg );
-- на сколько процентов отклоняется его зарплата от средней по отделу
--( diff ).
--*для округления используйте функцию round() .
--Сортировка результата: department , salary , employee_id
select
		first_name,
		department,
		salary,
		count(first_name) over (partition by department) as emp_cnt,
		round(avg(salary) over (partition by department), 0) as sal_avg,
		round((salary - avg(salary) over (partition by department)) / avg(salary) over (partition by department) * 100, 0) as diff
from employees
order by department, salary, employee_id;

--Задание 4. Нужно посчитать фонд оплаты труда нарастающим итогом (кумулятивная сумма)
--независимо для каждого департамента.
--Сортировка результата: department , salary , employee_id
select
		employee_id, first_name, department, salary,
		round(sum(salary) over
							(partition by department
							order by department , salary, employee_id
							rows between unbounded preceding and current row), 0)
							as total
from employees
order by department, salary, employee_id;