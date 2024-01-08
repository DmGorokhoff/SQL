--1. Найти все транзакции, которые совершал Calvin Potter
SELECT *
FROM coffe_shop.sales s 
WHERE customer_name = 'Calvin Potter'

--2. Посчитать средний чек покупателей по дням
SELECT
s.transaction_date, 
avg(quantity*unit_price) AS avg_bill
FROM coffe_shop.sales s
GROUP BY s.transaction_date
ORDER BY transaction_date ASC

--3. Преобразуйте дату транзакции в нужный формат: год, месяц, день.
--Приведите названия продуктов к стандартному виду в нижнем регистре
SELECT 
s.transaction_date,
date_part('year', date(s.transaction_date))  AS trans_year,
date_part('month', date(s.transaction_date))  AS trans_month,
date_part('day', date(s.transaction_date))  AS trans_day,
lower(s.product_name)  
FROM coffe_shop.sales s

--4. Сделать анализ покупателей и разделить их по категориям.
--Посчитать количество транзакций, сделанных каждым
--покупателем. Разделить их на категории: Частые гости (>= 23
--транзакций), Редкие посетители (< 10 транзакций), Стандартные
--посетители (все остальные)
SELECT
customer_id,
customer_name,
count(transaction_id) AS transactions,
CASE 
	WHEN count(customer_id) <10 THEN 'Редкий посетитель'
	WHEN count(customer_id) >=23 THEN 'Частый гость'
	ELSE 'Стандартный посетитель'
END AS customer_category 
FROM coffe_shop.sales s 
WHERE customer_id  != 0
GROUP BY 1,2
ORDER BY transactions DESC

--5. Посчитать количество уникальных посетителей в каждом магазине
--каждый день
SELECT 
transaction_date,
store_address,
count(DISTINCT s.customer_id) AS customers
FROM coffe_shop.sales s 
GROUP BY 1,2
ORDER BY store_address

--6. Посчитать количество клиентов по поколениям
SELECT
g.generation,
count(c.customer_name) AS customers_count
FROM coffe_shop.customer c  
LEFT JOIN coffe_shop.generations g
ON g.birth_year = c.birth_year 
GROUP BY 1
ORDER BY customers_count desc

--7. Найдите топ 10 самых продаваемых товаров каждый день и
--проранжируйте их по дням и кол-ву проданных штук
WITH sales_per_days AS (SELECT 
sr.transaction_date,
p.product_name,
count(p.product_name) AS quantity_ 
FROM coffe_shop.sales_reciepts sr 
LEFT JOIN coffe_shop.product p 
ON sr.product_id  = p.product_id 
GROUP BY 1,2
ORDER BY transaction_date, quantity_  desc
),

sales_wf AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY transaction_date ORDER BY transaction_date) AS rating_quantity_
FROM sales_per_days

)

SELECT*
FROM sales_wf
WHERE rating_quantity_<=10

--8. Выведите только те названия регионов, где продавался продукт
--“Columbian Medium Roast” с последней датой продажи
WITH t8 AS (
SELECT DISTINCT 
so.neighborhood,
ROW_NUMBER () OVER (PARTITION BY so.neighborhood ORDER BY transaction_date) AS rn,
LAST_VALUE(transaction_date) OVER (PARTITION BY neighborhood ORDER BY so.neighborhood) AS last_transaction
FROM coffe_shop.sales_reciepts sr 
LEFT JOIN coffe_shop.sales_outlet so 
ON sr.sales_outlet_id  = so.sales_outlet_id 
LEFT JOIN coffe_shop.product p 
ON p.product_id  = sr.product_id
WHERE product_name = 'Columbian Medium Roast'
)

SELECT DISTINCT 
neighborhood,
last_transaction
FROM t8
ORDER BY neighborhood

--9. Соберите витрину из следующих полей
SELECT
sr.transaction_date ,
so.sales_outlet_id ,
so.store_address,
p.product_id ,
p.product_name ,
c.customer_id ,
c.customer_name ,
CASE 
	WHEN c.gender = 'F' THEN REPLACE (c.gender, 'F', 'Famile') 
	WHEN c.gender = 'M' THEN REPLACE (c.gender, 'M', 'Mile')
	ELSE REPLACE (c.gender, 'N', 'Not Defined')
END AS g,
sr.unit_price ,
sr.quantity 
FROM coffe_shop.sales_reciepts sr 
LEFT JOIN coffe_shop.sales_outlet so 
ON sr.sales_outlet_id = so.sales_outlet_id 
LEFT JOIN coffe_shop.product p 
ON sr.product_id = p.product_id 
LEFT JOIN coffe_shop.customer c 
ON sr.customer_id = c.customer_id 

--10. Найдите разницу между максимальной и минимальной ценой
--товара в категории
WITH r_price AS 
(SELECT 
 product_category ,
 product_type ,
 product_name ,
 CAST(substring(current_retail_price, 2) AS NUMERIC)  AS retail_price
 --max(retail_price) OVER (PARTITION BY product_category) AS max_price_category 
 FROM coffe_shop.product p )
 
 SELECT *,
 max(retail_price) OVER (PARTITION BY product_category) AS max_price_category,
 min(retail_price) OVER (PARTITION BY product_category) AS min_price_category,
 max(retail_price) OVER (PARTITION BY product_category) - min(retail_price) OVER (PARTITION BY product_category) AS difference 
 FROM r_price




