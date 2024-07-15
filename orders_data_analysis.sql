--- 1. Find the top 10 highest revenue generating products ---
SELECT product_id, SUM(sale_price) AS sales 
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10



---2. Find the top 5 highest selling products in each region ---
WITH CTE AS (
SELECT product_id, region, SUM(sale_price) AS sales 
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM (
SELECT *, row_number() over(partition by region ORDER BY sales DESC) AS rn
FROM CTE) A
WHERE rn <= 5



---3. Find month over month growth comparison for 2022 and 2023 sales ---
WITH CTE as (
SELECT EXTRACT(YEAR FROM order_date) AS order_year, 
EXTRACT(MONTH FROM order_date) AS order_month, 
SUM(sale_price) AS sales 
FROM df_orders
GROUP BY order_year, order_month
--ORDER BY order_year, order_month
)
SELECT order_month,
SUM(CASE WHEN order_year = 2022 then sales else 0 end) AS sales_2022,
SUM(CASE WHEN order_year = 2023 then sales else 0 end) AS sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month



---4. For each category which month had highest sales ---
WITH CTE AS (
SELECT category, TO_CHAR(order_date,'yyyyMM') AS order_year_month, 
sum(sale_price) AS sales
FROM df_orders
GROUP BY category, TO_CHAR(order_date,'yyyyMM')
--ORDER BY category, TO_CHAR(order_date,'yyyyMM')
)
SELECT * FROM(
SELECT *, 
row_number() over(partition by category ORDER BY sales DESC) AS rn
FROM CTE
) A
WHERE rn=1



---5. Which subcategory had highest growth by profit in 2022 compare to 2023 ---
WITH CTE as (
SELECT sub_category, EXTRACT(YEAR FROM order_date) AS order_year, 
SUM(sale_price) AS sales 
FROM df_orders
GROUP BY sub_category, order_year
),
CTE2 AS (
SELECT sub_category,
SUM(CASE WHEN order_year = 2022 then sales else 0 end) AS sales_2022,
SUM(CASE WHEN order_year = 2023 then sales else 0 end) AS sales_2023
FROM CTE
GROUP BY sub_category
ORDER BY sub_category
)
SELECT *,
(sales_2023-sales_2022)*100/sales_2022
FROM CTE2
ORDER BY (sales_2023-sales_2022)*100/sales_2022 DESC
LIMIT 1



*.sql linguist-language=PLpgSQL
