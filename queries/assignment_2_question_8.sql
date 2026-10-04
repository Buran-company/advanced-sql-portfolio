-- purpose: create table with customers who have orders

-- grain: one row per customer with orders

SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    ord_sum.order_count,
    ord_sum.total_spend,
    ord_sum.avg_order_value,
    ord_sum.last_order_date
FROM 
    customers AS c
JOIN (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        SUM(amount) AS total_spend,
        ROUND(AVG(amount), 2) AS avg_order_value,
        MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
) AS ord_sum
    ON c.customer_id = ord_sum.customer_id
ORDER BY 
    ord_sum.total_spend DESC, c.customer_id;