-- purpose: select completed orders with customer info

-- grain: one row per one completed order

SELECT
    c.customer_name,
    c.segment,
    c.region,
    o.order_date,
    o.amount
FROM 
    orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
WHERE 
    o.status = 'Completed'
ORDER BY 
    o.order_date, o.order_id;