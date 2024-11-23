create database zomato;
use zomato;
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date);

INSERT INTO goldusers_signup(userid, gold_signup_date) 
VALUES (1, '2017-09-22'), (3, '2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid, signup_date) 
VALUES (1, '2014-09-02'),
       (2, '2015-01-15'),
       (3, '2014-04-11');


drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid, created_date, product_id) 
VALUES 
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from goldusers_signup;
select * from users;
select * from sales;
select * from product;
show databases;

SELECT s.userid, SUM(p.price) AS total_spent
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
GROUP BY s.userid
ORDER BY s.userid;

SELECT s.userid, COUNT(DISTINCT s.created_date) AS days_visited
FROM sales AS s
GROUP BY s.userid
ORDER BY s.userid;

SELECT s.userid, p.product_name AS first_product
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
JOIN users AS u ON s.userid = u.userid
WHERE s.created_date >= u.signup_date
AND s.created_date = (
    SELECT MIN(created_date)
    FROM sales
    WHERE userid = s.userid
)
ORDER BY s.userid;

SELECT p.product_name, COUNT(s.product_id) AS purchase_count
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY purchase_count DESC
LIMIT 1;

WITH star AS (
    SELECT userid, product_id, COUNT(product_id) AS m
    FROM sales
    GROUP BY userid, product_id
),
star2 AS (
    SELECT *, RANK() OVER (PARTITION BY userid ORDER BY m DESC) AS fav_product
    FROM star
)
SELECT userid, product_id, m
FROM star2
WHERE fav_product = 1;

SELECT s.userid, p.product_name, MIN(s.created_date) AS first_purchase_date
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
JOIN goldusers_signup AS g ON s.userid = g.userid
WHERE s.created_date > g.gold_signup_date
GROUP BY s.userid, p.product_name
ORDER BY s.userid;

SELECT s.userid, p.product_name, MAX(s.created_date) AS last_purchase_date
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
JOIN goldusers_signup AS g ON s.userid = g.userid
WHERE s.created_date < g.gold_signup_date
GROUP BY s.userid, p.product_name
ORDER BY s.userid;

SELECT s.userid, 
       COUNT(s.product_id) AS total_orders, 
       SUM(p.price) AS total_amount_spent
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
JOIN goldusers_signup AS g ON s.userid = g.userid
WHERE s.created_date < g.gold_signup_date
GROUP BY s.userid
ORDER BY s.userid;

SELECT s.userid, 
       s.created_date, 
       p.product_name, 
       p.price, 
       RANK() OVER (PARTITION BY s.userid ORDER BY p.price DESC) AS transaction_rank
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
ORDER BY s.userid, transaction_rank;

SELECT s.userid,
       COUNT(s.product_id) AS total_orders,
       AVG(p.price) AS avg_order_value
FROM sales AS s
JOIN product AS p ON s.product_id = p.product_id
GROUP BY s.userid;