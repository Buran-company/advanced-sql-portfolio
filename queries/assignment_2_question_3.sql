-- purpose: investigate the risk of rows duplication when joining the orders with addresses through customer_id

-- grain: one row per one customer

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT a.address_id) AS address_count,
    COUNT(DISTINCT o.order_id) * COUNT(DISTINCT a.address_id) AS potential_joined_rows
FROM 
    customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN addresses AS a
    ON c.customer_id = a.customer_id
GROUP BY 
    c.customer_id, c.customer_name
ORDER BY 
    address_count DESC, potential_joined_rows DESC, c.customer_id
LIMIT 
    10;