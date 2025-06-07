Coffee Consumers Count
SELECT 
    city_name,
    ROUND(CAST(population * 0.25 AS FLOAT) / 1000000, 2) AS coffee_consumers_in_millions,
    city_rank
FROM city
ORDER BY coffee_consumers_in_millions DESC;

Total Revenue from Coffee Sales
-- Total revenue across all cities
SELECT 
    SUM(total) AS total_revenue
FROM sales
WHERE 
    YEAR(sale_date) = 2023
    AND DATEPART(QUARTER, sale_date) = 4;

-- Total revenue by city
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales AS s
INNER JOIN customers AS c ON s.customer_id = c.customer_id
INNER JOIN city AS ci ON ci.city_id = c.city_id
WHERE 
    YEAR(s.sale_date) = 2023
    AND DATEPART(QUARTER, s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

Sales Count for Each Product
SELECT 
    p.product_name,
    COUNT(s.sale_id) AS total_orders
FROM products AS p
LEFT JOIN sales AS s ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC;

Average Sales Amount per City
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(CAST(SUM(s.total) AS FLOAT) / CAST(COUNT(DISTINCT s.customer_id) AS FLOAT), 2) AS avg_sale_pr_cx
FROM sales AS s
INNER JOIN customers AS c ON s.customer_id = c.customer_id
INNER JOIN city AS ci ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

City Population and Coffee Consumers (25%)

WITH city_table AS 
(
    SELECT 
        city_name,
        ROUND(CAST(population * 0.25 AS FLOAT) / 1000000, 2) AS coffee_consumers
    FROM city
),
customers_table AS
(
    SELECT 
        ci.city_name,
        COUNT(DISTINCT c.customer_id) AS unique_cx
    FROM sales AS s
    INNER JOIN customers AS c ON c.customer_id = s.customer_id
    INNER JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
)
SELECT 
    customers_table.city_name,
    city_table.coffee_consumers AS coffee_consumer_in_millions,
    customers_table.unique_cx
FROM city_table
INNER JOIN customers_table ON city_table.city_name = customers_table.city_name;

Top Selling Products by City
SELECT * 
FROM (
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) AS total_orders,
        DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS rank
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    INNER JOIN customers AS c ON c.customer_id = s.customer_id
    INNER JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, p.product_name
) AS t1
WHERE rank <= 3;

Customer Segmentation by City
SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cx
FROM city AS ci
LEFT JOIN customers AS c ON c.city_id = ci.city_id
INNER JOIN sales AS s ON s.customer_id = c.customer_id
WHERE 
    s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY ci.city_name;

Average Sale vs Rent
WITH city_table AS
(
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(CAST(SUM(s.total) AS FLOAT) / CAST(COUNT(DISTINCT s.customer_id) AS FLOAT), 2) AS avg_sale_pr_cx
    FROM sales AS s
    INNER JOIN customers AS c ON s.customer_id = c.customer_id
    INNER JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
),
city_rent AS
(
    SELECT 
        city_name, 
        estimated_rent
    FROM city
)
SELECT 
    cr.city_name,
    cr.estimated_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,
    ROUND(CAST(cr.estimated_rent AS FLOAT) / CAST(ct.total_cx AS FLOAT), 2) AS avg_rent_per_cx
FROM city_rent AS cr
INNER JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY ct.avg_sale_pr_cx DESC;

Monthly Sales Growth
WITH monthly_sales AS
(
    SELECT 
        ci.city_name,
        MONTH(sale_date) AS month,
        YEAR(sale_date) AS year,
        SUM(s.total) AS total_sale
    FROM sales AS s
    INNER JOIN customers AS c ON c.customer_id = s.customer_id
    INNER JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, MONTH(sale_date), YEAR(sale_date)
),
growth_ratio AS
(
    SELECT
        city_name,
        month,
        year,
        total_sale AS cr_month_sale,
        LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) AS last_month_sale
    FROM monthly_sales
)
SELECT
    city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    ROUND(CAST((cr_month_sale - last_month_sale) AS FLOAT) / NULLIF(CAST(last_month_sale AS FLOAT), 0) * 100, 2) AS growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL;

Market Potential Analysis
WITH city_table AS
(
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(CAST(SUM(s.total) AS FLOAT) / CAST(COUNT(DISTINCT s.customer_id) AS FLOAT), 2) AS avg_sale_pr_cx
    FROM sales AS s
    INNER JOIN customers AS c ON s.customer_id = c.customer_id
    INNER JOIN city AS ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
),
city_rent AS
(
    SELECT 
        city_name, 
        estimated_rent,
        ROUND(CAST(population * 0.25 AS FLOAT) / 1000000, 3) AS estimated_coffee_consumer_in_millions
    FROM city
)
SELECT TOP 3
    cr.city_name,
    ct.total_revenue,
    cr.estimated_rent AS total_rent,
    ct.total_cx,
    cr.estimated_coffee_consumer_in_millions,
    ct.avg_sale_pr_cx,
    ROUND(CAST(cr.estimated_rent AS FLOAT) / CAST(ct.total_cx AS FLOAT), 2) AS avg_rent_per_cx
FROM city_rent AS cr
INNER JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY ct.total_revenue DESC;