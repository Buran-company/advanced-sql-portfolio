-- purpose: select orders with missing data in customer table

-- grain: one row per one order with missing data in customer table

-- 5 rows

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.amount
FROM 
    orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE 
    c.customer_id IS NULL
ORDER BY 
    o.order_id;