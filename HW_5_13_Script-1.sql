--Counts number of employees working in each department
select department, count(first_name) as num_employees from employees
group by department
order by count(first_name) desc;

--Selects everything from the table
select * from employees;

--Counts total budget arcoss departments
select department, round(sum(salary), 0) as budget from employees
group by department
order by sum(salary) desc;

--Filters names of emplyees earning not less than $80K
select first_name, last_name, salary from employees
where salary >= 80000;

--Counts total budget across departments and the number of employees working in each one
select
		department,
		round(sum(salary), 0) as budget,
		count(first_name) as num_employees
from employees
group by department
order by sum(salary) desc;

select * from flight_detail;

select * from aircompany_detail;

select * from aircompany_detail a
join flight_detail f on a.aircompany_id = f.aircompany_id;

select ad.aircompany_name, sum(fd.passengers) as total_pax
from flight_detail fd 
join aircompany_detail ad on fd.aircompany_id = ad.aircompany_id
group by ad.aircompany_name;

--Задание 1. С помощью CTE напиши скрипт, который достает название авиакомпании, номер рейса,
--количество пассажиров на рейсе, общее количество пассажиров, которое перевезла авиакомпания
with total_passengers as (
	select
		aircompany_id,
		sum(passengers) as total_pax
	from flight_detail fd 
	group by aircompany_id 
)
select 
    ad.aircompany_name,
    fd.flight_number,
    fd.passengers,
    tp.total_pax
from flight_detail fd
join aircompany_detail ad
    on fd.aircompany_id = ad.aircompany_id
join total_passengers tp
	on fd.aircompany_id = tp.aircompany_id;


--Задание 2. Из таблицы course_schema.flight_details с помощью вложенного запроса вывести номер рейса и
--количество пассажиров, где количество пассажиров больше или равно среднему количеству
--пассажиров в таблице course_schema.flight_details
select flight_number, passengers
from flight_detail
where passengers >= (select avg(passengers)
						from flight_detail);

--Задание 3. Получить полный список книг, которые есть в библиотеке из таблиц course_schema.books_archive и course_schema.books (убрать дубли).
--Вывести весь список книг, добавить к нему колонку status, которая должна содержать текст "Дешевле среднего" в случае, когда цена ниже средней цены
--из общего списка книг и текст "Дороже среднего" во всех иных случаях.
select book_id, title, author, genre, price from books

select book_id, title, author, genre, price from books_archive;



with all_books as (
	select book_id, title, author, genre, price from books
	union
	select book_id, title, author, genre, price from books_archive
),
average_price as (
	select avg(price) as avg_price
	from all_books
)
select
	ab.book_id,
	ab.title,
	ab.author,
	ab.genre,
	ab.price,
	case 
		when ab.price < ap.avg_price then 'Дешевле среднего'
		else 'Дороже среднего'
	end as status
from
	all_books ab,
	average_price ap;
	


