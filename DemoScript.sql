--Скрипт хранится по адресу:
--C:\Users\internet\AppData\Roaming\DBeaverData\workspace6\General\Scripts\Script-5.sql

-- обзор таблицы
SELECT *
FROM Album;

-- подсчет кол-ва строк в таблице
SELECT
count(*) AS c
FROM Album;

-- отбор альбомов по фильтру
SELECT *
FROM Album
WHERE "Title" LIKE "%W%";

SELECT *
FROM Album
WHERE Column1 is NULL;

SELECT *
FROM Album
WHERE Column1 != "NULL";

SELECT *
FROM Album
WHERE Column1 IS not NULL;

-- подсчет кол-ва строк с NULL
SELECT Column1,
COUNT (*) AS cntIsNull
FROM Album
WHERE Column1 IS NULL; 

-- подсчет кол-ва строк без NULL
SELECT "[isNotNull]" as str,
COUNT (*) AS cAlbumId 
FROM Album
WHERE Column1 IS NOT NULL;

-- сортировка по возрастанию по исполнителям
SELECT *
FROM Album
ORDER BY ArtistId;

---- сортировка по возрастанию по исполнителям и фильтация по исполнителям
SELECT *
FROM Album
WHERE ArtistId IN (1,2,5,15)
ORDER BY ArtistId;

--кол-во альбомов, сгруппированных по исполнителям с сортировкой по убыванию
SELECT ArtistId, 
	COUNT(Title) AS cArtistId
FROM Album
GROUP BY ArtistId
ORDER BY cArtistId DESC; 

-- кол-во альбомов по выбранным исполнителям
SELECT ArtistId, 
	COUNT(ArtistId) AS cArtistId
FROM Album
GROUP BY ArtistId
HAVING ArtistId in (1,2,22,90,58)

--альбомы AC/DC в списке
SELECT *,
LENGTH(Title) AS lengthTitle,
CASE 
	WHEN ArtistId = 1 THEN "AC/DC"
	ELSE "Other"
END AS "Group"
FROM Album
WHERE "Group" LIKE "AC/DC";

--кол-во альбомов у каждого исполнителя
SELECT artistid,
	count(Title) AS countAlbums 
FROM Album 
GROUP BY ArtistId 
ORDER BY countAlbums DESC

--кол-во альбомов у каждого исполнителя (подзапрос)
SELECT *
FROM 
	(SELECT ArtistId,  
	count(Title) AS countAlbums 
	FROM Album
	GROUP BY ArtistId) AS cA
ORDER BY countAlbums DESC 

-- исполнители с кол-ом альбомов от 10 до 14
SELECT * 
FROM 
	(SELECT artistid,
	count(Title) AS countAlbums 
	FROM Album 
	GROUP BY ArtistId 
	ORDER BY countAlbums DESC) AS cT
WHERE countAlbums BETWEEN 10 AND 14;

--среднее кол-во альбомов на исполнителя
SELECT 
	AVG(
	(SELECT 
	count(Title) AS countAlbums 
	FROM Album 
	GROUP BY ArtistId)	
	) AS avgCountAlbums
FROM Album;

-- отбор исполнителей, у которых кол-во альбомов больше среднего
SELECT ArtistId,
count(Title) AS countAlbums
FROM Album
GROUP BY ArtistId
HAVING countAlbums > (SELECT AVG((SELECT count(Title) AS countAlbums FROM Album GROUP BY ArtistId)) FROM Artist)
ORDER BY countAlbums DESC;

-- создание обобщенного табличного выражения
with cte_name as 
(
SELECT *
FROM 
	(SELECT ArtistId,  
	count(Title) AS countAlbums 
	FROM Album
	GROUP BY ArtistId) AS cA
ORDER BY countAlbums DESC
)
SELECT *
FROM cte_name
WHERE countAlbums BETWEEN 5 AND 14;

--нумерованный список уникальных названий городов
SELECT row_number() over() AS n, *
FROM (
	 SELECT DISTINCT city
	 FROM Employee
	 ) AS nC;

-- подсчет уникальных названий городов
SELECT
COUNT(*) AS cntCity  
FROM (
	 SELECT DISTINCT city 
	 FROM Employee
	 ) AS cC;	

--подсчет количества в списке уникальных названий городов
SELECT 
ROW_NUMBER() over() as rN
,COUNT(*) over () as cntCity
,city
FROM (
SELECT DISTINCT city
FROM Employee);

--соединение 4-х таблиц
SELECT DISTINCT Album.ArtistId, Artist.Name, Title, Composer, Genre.Name as GenreMusic, Track.UnitPrice 
FROM Album
Left Join Artist
on Album.ArtistId = Artist.ArtistId
LEFT JOIN Track
on Album.AlbumId = Track.AlbumId
LEFT JOIN Genre
on Track.GenreId = Genre.GenreId
ORDER by Track.UnitPrice DESC;
 
 -- подсчет строк в таблице
SELECT
count(*)
FROM (
	SELECT Album.ArtistId, Artist.Name, Title
	FROM Album
	Left Join Artist
	on Album.ArtistId = Artist.ArtistId
 	);

 SELECT*
 FROM Track;
 
-- кол-во уникальных жанров
SELECT
count(DISTINCT GenreId)
FROM Track;

-- подсчет суммы UnitPrice по жанрам музыки
SELECT DISTINCT Album.ArtistId, Artist.Name, Title, Composer, Genre.Name as GenreMusic, Track.UnitPrice,
SUM(UnitPrice) OVER (PARTITION by Genre.Name) as sumUP 
FROM Album
Left Join Artist
on Album.ArtistId = artist.ArtistId
LEFT JOIN Track
on Album.AlbumId = Track.AlbumId
LEFT JOIN Genre
on Track.GenreId = Genre.GenreId
ORDER by sumUP DESC;

-- Нумерация строк таблицы
SELECT *,
ROW_NUMBER() OVER () as rankCity
FROM (SELECT Country, City, Company,   
COUNT(City) over (PARTITION by Country) as cCity
FROM Customer
order by cCity DESC);

-- ранжирование стран по числу городов пользователей
SELECT *,
DENSE_RANK() OVER (ORDER BY cCity DESC) as rankCity
FROM (SELECT Country, City, Company,   
COUNT(City) over (PARTITION by Country) as cCity
FROM Customer
order by cCity DESC);

-- подсчет уникальных стран в таблице
SELECT 
count(DISTINCT Country)
FROM 
(SELECT *,
DENSE_RANK() OVER (ORDER BY cCity DESC) as rankCity
FROM (SELECT Country, City, Company,   
COUNT(City) over (PARTITION by Country) as cCity
FROM Customer
order by cCity DESC));

-- подсчет кол-ва компаний, стран, городов в таблице 
SELECT
COUNT(DISTINCT Company) as cComp,
COUNT(DISTINCT Country) as cCountry,
COUNT(DISTINCT City) as cCity
FROM Customer;

-- подсчет сумм покупок в разрезе покупателей и стран с проставлением рейтинга
With t_cte as (
SELECT i.CustomerId, c.FirstName,  c.LastName, c.Company, c.City, c.Country,  
SUM(Total) as sT
FROM Invoice i  
left join Customer c
on i.CustomerId = c.CustomerId
group by i.CustomerId
ORDER BY 7 DESC),

t2 as (SELECT *,
ROUND(SUM(sT) over (PARTITION by country), 2) as sTResult
FROM t_cte
ORDER BY 8 DESC)

SELECT *,
DENSE_RANK() OVER (ORDER BY sTResult DESC) as rResult
FROM t2
ORDER BY 8 DESC

--подсчет суммы продаж в разрезе композиторов
SELECT*
,SUM(UnitPrice) over (PARTITION by Composer ) as totalSum
from Track
WHERE Composer is NOT NULL
ORDER by totalSum DESC; 

--подсчет суммы продаж по месяцам
SELECT
strftime('%m', InvoiceDate) as iM
,SUM(Total) as sT 
FROM Invoice
group by iM
order by InvoiceDate;

--подсчет суммы нарастающим итогом
SELECT*
, sum(sT) over (ROWS between unbounded preceding and CURRENT ROW) as sumTotal 
FROM
(SELECT 
strftime('%m', InvoiceDate) as iM
,SUM(Total) as sT 
FROM Invoice
group by iM
order by InvoiceDate);

--подсчет поквартальной суммы нарастающим итогом с разбивкой по полугодиям
with tst as (
SELECT *
, SUM(sT) OVER (PARTITION BY q) as sQ 
FROM (
SELECT*
, sum(sT) over (ROWS between unbounded preceding and CURRENT ROW) as sumTotal
, 
CASE 
	WHEN iM IN ("01","02","03") THEN "1q"
	WHEN iM IN ("04","05","06") THEN "2q"
	WHEN iM IN ("07","08","09") THEN "3q"
	ELSE "4q"
END AS q
FROM
(SELECT 
strftime('%m', InvoiceDate) as iM
,SUM(Total) as sT 
FROM Invoice
group by iM
order by InvoiceDate)
)
)
SELECT *,
sum(sT) OVER (PARTITION by p) as sP
FROM 
(SELECT *
, 
CASE 
	WHEN q in ('1q', '2q') THEN '1p'
	ELSE '2p'
END AS p 
FROM tst);

--оконная функция с фреймами (подсчет скользящего среднего) 
SELECT*
, ROUND(AVG(sT) over (ROWS between UNBOUNDED preceding and UNBOUNDED FOLLOWING),2) as avg_sT
, ROUND(AVG(sT) over (ROWS between 1 PRECEDING  AND 1 FOLLOWING),2) as movAvg --расчет скользящего среднего
, ROUND(AVG(sT) over (ROWS between 1 PRECEDING  AND 1 FOLLOWING),2) - ROUND(AVG(sT) over (),2) as chgAvg --аналогия 1-ой строки SELECT
FROM
(SELECT 
strftime('%m', InvoiceDate) as iM
,SUM(Total) as sT 
FROM Invoice
group by iM
order by InvoiceDate);

--подсчет изменений от месяца к месяцу
SELECT *
,lag(sT) over (ORDER by iM) as sT1
,sT - lag(sT) over (ORDER by iM) as chng
,lag(sT,3) over () as sT2 --пример создания копии столбца с одним значением со смещением на 3 строки
FROM 
(SELECT 
strftime('%m', InvoiceDate) as iM
,SUM(Total) as sT 
FROM Invoice
group by iM
order by InvoiceDate
);

--нумерация строк в таблице
SELECT DISTINCT
row_number() over () as n
, FirstName 
, LastName 
FROM Customer;

--фильтрация по строковым символам
SELECT *
FROM Album a 
LEFT JOIN	Artist a2 ON a.AlbumId = a2.ArtistId 
WHERE a2.Name LIKE 'A%'
AND a.Title LIKE '%W%'

--вычисление нескольких оконных функции
SELECT*, count(artistid) OVER w AS c, sum(artistid) OVER w AS s
FROM Album 
	WINDOW w AS (PARTITION BY artistid);
