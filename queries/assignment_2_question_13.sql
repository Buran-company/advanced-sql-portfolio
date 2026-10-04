-- purpose: rank products by revenue in each region (top-3 revenue rank)

-- grain: one row per region+product (top-3)

WITH region_product_revenue AS (
    SELECT
        COALESCE(c.region, 'Unmatched') AS region,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount_pct, 0) / 100.0)) AS product_revenue
    FROM 
        orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS p
        ON oi.product_id = p.product_id
    WHERE 
        o.status = 'Completed'
    GROUP BY 
        COALESCE(c.region, 'Unmatched'), p.product_id, p.product_name
),
ranked_products AS (
    SELECT
        region,
        product_id,
        product_name,
        product_revenue,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY product_revenue DESC) AS revenue_rank
    FROM 
        region_product_revenue
)
SELECT
    region,
    revenue_rank,
    product_id,
    product_name,
    ROUND(product_revenue, 2) AS product_revenue
FROM 
    ranked_products
WHERE 
    revenue_rank <= 3
ORDER BY 
    region, revenue_rank, product_revenue DESC;