-- purpose: create feature table with customers including inactive

-- grain: one row per customer

WITH completed_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        amount
    FROM 
        orders
    WHERE 
        status = 'Completed'
),
customer_metrics AS (
    SELECT
        customer_id,
        COUNT(order_id) AS completed_order_count,
        COALESCE(SUM(amount), 0.00) AS completed_spend,
        MAX(order_date) AS last_completed_order_date
    FROM 
        completed_orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    c.region,
    c.status,
    COALESCE(cm.completed_order_count, 0) AS completed_order_count,
    COALESCE(cm.completed_spend, 0.00) AS completed_spend,
    cm.last_completed_order_date,
    CASE
        WHEN cm.last_completed_order_date IS NULL THEN NULL
        ELSE (DATE '2026-12-31' - cm.last_completed_order_date)
    END AS days_since_last_order
FROM 
    customers AS c
LEFT JOIN customer_metrics AS cm
    ON c.customer_id = cm.customer_id
ORDER BY 
    completed_spend DESC, c.customer_id;