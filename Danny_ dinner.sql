CREATE database dannys_diner;

Drop databse dannys_diner

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE "menu" (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO "menu"
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE "members" (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO "members"
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


Select * from INFORMATION_SCHEMA.TABLES



        --Danny's Diner
 ---1. What is the total amount each customer spent at the restaurant?
SELECT
customer_id, sum(price) as amount
from dannys_diner..sales
join dannys_diner..menu
on sales.product_id =menu.product_id
Group by customer_id;


--- 2. How many days has each customer visited the restaurant?
SELECT
customer_id, count(*)
from dannys_diner..sales
Group by customer_id;


----3. What was the first item from the menu purchased by each customer?

with ranking as(

SELECT
  	 customer_id,
    m.product_name,
    order_date,
   
    rank() over(partition by (customer_id) order by (order_date)) rank
FROM dannys_diner..menu as m
join dannys_diner..sales as s
on m.product_id = s.product_id
Group by customer_id, m.product_name, order_date
)

select customer_id, product_name,order_date
from ranking
where rank= 1

---4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT Top 1
product_name,count(product_name)as most_purchased
from dannys_diner..sales
join dannys_diner..menu
on sales.product_id = menu.product_id
Group by Product_name
order by most_purchased desc



 ---5. Which item was the most popular for each customer?
with ranks as

(SELECT count(*) as count, customer_id,product_name,
rank() over(partition by(customer_id) order by count(product_name) DESC)  as ranking
FROM dannys_diner..sales s
join dannys_diner..menu as m
on s.product_id = m.product_id 
Group by customer_id,product_name)

select customer_id, product_name
from ranks
where ranking= 1



----6 Which item was purchased first by the customer after they became a member?
with ranking as(

SELECT
  	 s.customer_id,
    m.product_name,
    order_date,
   
    rank() over(partition by (s.customer_id) order by (order_date)) as ranks
FROM dannys_diner..members as mem
join dannys_diner..sales as s
on mem. customer_id= s. customer_id
join dannys_diner..menu as m
on m.product_id = s.product_id
where order_date >= join_date 
Group by s.customer_id, m.product_name, order_date)

select customer_id, product_name,order_date
from ranking
where ranks= 1


----7 Which item was purchased just before the customer became a member?
with ranking as(

SELECT
  	 mem.customer_id,
    m.product_name,
    order_date,
    join_date,
   
    rank() over(partition by (mem.customer_id) order by (order_date) desc ) rank
FROM dannys_diner..menu as m
join dannys_diner..sales as s
on m.product_id = s.product_id
join dannys_diner..members as mem
on mem.customer_id = s.customer_id 
where order_date < join_date
Group by mem.customer_id, m.product_name, order_date, join_date
)

select customer_id, product_name,order_date
from ranking
where rank= 1

---8 What is the total items and amount spent for each member before they became a member?

SELECT
  	 mem.customer_id,
     count(s.product_id) as counts,
     sum (price) as amount
     
FROM dannys_diner..menu as m
join dannys_diner..sales as s
on m.product_id = s.product_id
join dannys_diner..members as mem
on mem.customer_id = s.customer_id 
Group by mem.customer_id

---9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
--- how many points would each customer have?

with points as (
  
SELECT
  	 customer_id,
     case
     when product_name = 'sushi' then 20
     else 10
     end as pointers
FROM dannys_diner..menu as m
join dannys_diner..sales as s
on m.product_id = s.product_id)

select customer_id, sum(pointers) as total_points
from points
Group by customer_id
