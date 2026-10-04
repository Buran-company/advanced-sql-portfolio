-- purpose: select unique products purchased by Enterprise customers in completed orders (in and exists)

-- grain: one row per unique product

-- in

SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM 
    products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE 
    o.status = 'Completed'
    AND o.customer_id IN (
        SELECT customer_id
        FROM customers
        WHERE segment = 'Enterprise'
    )
ORDER BY 
    p.product_id;

-- exists

SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM 
    products AS p
WHERE EXISTS (
    SELECT 1
    FROM order_items AS oi
    JOIN orders AS o ON oi.order_id = o.order_id
    JOIN customers AS c ON o.customer_id = c.customer_id
    WHERE 
        oi.product_id = p.product_id
        AND o.status = 'Completed'
        AND c.segment = 'Enterprise'
)
ORDER BY 
    p.product_id;