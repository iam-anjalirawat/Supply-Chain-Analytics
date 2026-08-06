--SUPPLY CHAIN ANALYTICS PROJECT

CREATE TABLE supply_chain (
    product_type VARCHAR(50),
    sku VARCHAR(30),
    price NUMERIC(10,2),
    availability INT,
    products_sold INT,
    revenue_generated NUMERIC(12,2),
    customer_demographics VARCHAR(30),
    stock_levels INT,
    lead_times INT,
    order_quantities INT,
    shipping_times INT,
    shipping_carriers VARCHAR(50),
    shipping_costs NUMERIC(10,2),
    supplier_name VARCHAR(100),
    location VARCHAR(100),
    lead_time INT,
    production_volumes INT,
    manufacturing_lead_time INT,
    manufacturing_costs NUMERIC(10,2),
    inspection_results VARCHAR(30),
    defect_rates NUMERIC(5,2),
    transportation_modes VARCHAR(50),
    routes VARCHAR(50),
    costs NUMERIC(10,2)
);


--Business Problems--

1. Which product categories generate the highest total revenue?

SELECT
	product_type,
	SUM(revenue_generated) as Total_revenue
FROM supply_chain
GROUP BY 1
ORDER BY 2 DESC;

2. What are the Top 10 SKUs contributing the most revenue?

SELECT
	sku,
	product_type,
	ROUND(revenue_generated,0) as revenue
FROM supply_chain
ORDER BY 3 DESC
LIMIT 10;

3. Which products have the highest sales volume but relatively low revenue?

SELECT
	sku,
	product_type,
	products_sold,
	revenue_generated
FROM supply_chain
WHERE products_sold >
(
SELECT 
	AVG(products_sold)
FROM supply_chain
)
AND revenue_generated <
(
SELECT 
	AVG(revenue_generated) as avg_revenue
FROM supply_chain
)
ORDER BY products_sold DESC;

4. Which products are at risk of stock shortages based on stock levels and sales?

SELECT
    sku,
    product_type,
    stock_levels,
    products_sold,
    CASE
        WHEN stock_levels < (
            SELECT AVG(stock_levels)
            FROM supply_chain
        )
        AND products_sold > (
            SELECT 
				AVG(products_sold)
            FROM supply_chain
        )THEN 'High Risk'
        WHEN stock_levels < (
            SELECT 
				AVG(stock_levels)
            FROM supply_chain
        )THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS stock_risk
FROM supply_chain
ORDER BY 
	stock_levels ASC, 
	products_sold DESC;

5. Which products have high inventory but low sales?

SELECT
    sku,
    product_type,
    stock_levels,
    products_sold
FROM supply_chain
WHERE stock_levels >
	(
	SELECT AVG(stock_levels)
	FROM supply_chain
	)
	AND products_sold <
	(
	SELECT AVG(products_sold)
	FROM supply_chain
	)
ORDER BY stock_levels DESC;

6. Which product category has the highest average inventory level?

SELECT
    product_type,
    ROUND(AVG(stock_levels),2) AS average_stock
FROM supply_chain
GROUP BY 1
ORDER BY 2 DESC;

7. Which shipping carrier has the lowest average shipping time?

SELECT
	shipping_carriers,
	ROUND(AVG(shipping_times),0) as avg_shipping_time
FROM supply_chain
GROUP BY 1
ORDER BY 2 ASC;

8. Compare transportation modes by average shipping cost and average delivery time.

SELECT
	transportation_modes,
	COUNT(*) AS total_shipments,
	ROUND(AVG(shipping_costs),0) as avg_shipping_costs,
	ROUND(AVG(shipping_times),0) as avg_shipping_times
FROM supply_chain
GROUP BY 1
ORDER BY 3;

9. Which shipping routes incur the highest logistics costs?

SELECT
	routes,
	SUM(shipping_costs) as Total_logistics_costs
FROM supply_chain
GROUP BY 1
ORDER BY 2 DESC;

10. Rank suppliers based on total revenue generated and average manufacturing cost.

SELECT
    supplier_name,
    ROUND(SUM(revenue_generated),0) AS total_revenue,
    ROUND(AVG(manufacturing_costs),0) AS avg_manufacturing_cost,
    RANK() OVER(ORDER BY SUM(revenue_generated) DESC) AS supplier_rank
FROM supply_chain
GROUP BY 1;

11. Which suppliers have the highest average defect rates?

SELECT
    supplier_name,
    ROUND(AVG(defect_rates),2) AS average_defect_rate
FROM supply_chain
GROUP BY 1
ORDER BY 2 DESC;

12. Which manufacturing lead times produce the highest revenue?

SELECT
	manufacturing_lead_time,
	ROUND(AVG(revenue_generated),2) revenue
FROM supply_chain
GROUP BY 1
ORDER BY 2 DESC;

13. Which product types have the highest average defect rates and inspection failures?

SELECT
    product_type,
    inspection_results,
    ROUND(AVG(defect_rates),2) AS average_defect_rate
FROM supply_chain
GROUP BY
    1,
    2
ORDER BY 3 DESC;

14. Which supplier contributes the highest revenue within each product category?

WITH supplier_rank AS
(
SELECT
	product_type,
	supplier_name,
	SUM(revenue_generated) revenue,
	ROW_NUMBER() OVER(PARTITION BY product_type ORDER BY SUM(revenue_generated) DESC) rn
FROM supply_chain
GROUP BY
1,
2
)
SELECT *
FROM supplier_rank
WHERE rn=1;

15. Which products perform above their product category average revenue?

SELECT
	sku,
	product_type,
	revenue_generated,
	ROUND(AVG(revenue_generated)OVER(PARTITION BY product_type),2) AS category_avg,
	ROUND(revenue_generated-AVG(revenue_generated)OVER(PARTITION BY product_type),2) AS difference
FROM supply_chain
ORDER BY 5 DESC;

