-- purpose: produce monthly completed revenue and order count by region for 2026

-- grain: one row per month+region

WITH base_orders_2026 AS (
    SELECT
        o.order_id,
        o.order_date,
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        o.amount,
        COALESCE(c.region, 'Unmatched') AS region
    FROM 
        orders AS o
    LEFT JOIN customers AS c
        ON o.customer_id = c.customer_id
    WHERE 
        o.status = 'Completed'
        AND o.order_date >= DATE '2026-01-01'
        AND o.order_date < DATE '2027-01-01'
),
monthly_regional_agg AS (
    SELECT
        order_month,
        region,
        SUM(amount) AS total_completed_revenue,
        COUNT(order_id) AS completed_order_count
    FROM 
        base_orders_2026
    GROUP BY 
        order_month, region
)
SELECT
    order_month,
    region,
    ROUND(total_completed_revenue, 2) AS total_completed_revenue,
    completed_order_count
FROM 
    monthly_regional_agg
ORDER BY 
    order_month, region;