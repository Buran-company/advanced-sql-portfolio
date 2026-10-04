-- purpose: form regional KPIs using conditional aggregation

-- grain: one row per region

SELECT
    COALESCE(c.region, 'Unmatched') AS region,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(SUM(CASE WHEN o.status = 'Completed' THEN o.amount ELSE 0 END), 2) AS completed_revenue,
    ROUND(AVG(CASE WHEN o.status = 'Completed' THEN o.amount END), 2) AS avg_completed_order_amount,
    ROUND(
        100.0 * SUM(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(o.order_id), 0),
        2
    ) AS completion_rate_pct
FROM 
    orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY 
    COALESCE(c.region, 'Unmatched')
ORDER BY 
    completed_revenue DESC, region;