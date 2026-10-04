-- purpose: select each order with the city and country of the shipping address

-- grain: one row per one order

SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.amount,
    a.city,
    a.country,
    CASE
        WHEN o.shipping_address_id IS NULL THEN 'Missing Address ID'
        WHEN a.address_id IS NULL THEN 'Unmatched Address'
        ELSE 'Matched'
    END AS match_status
FROM orders AS o
LEFT JOIN addresses AS a
    ON o.shipping_address_id = a.address_id
ORDER BY 
    o.order_id;