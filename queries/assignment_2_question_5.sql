-- purpose: select completed orders, which sum is bigger than average sum among completed orders

-- grain: one row per one completed order bigger than average

SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    ROUND(amount - (SELECT AVG(amount) FROM orders WHERE status = 'Completed'), 2) AS diff_from_avg
FROM 
    orders
WHERE 
    status = 'Completed'
    AND amount > (SELECT AVG(amount) FROM orders WHERE status = 'Completed')
ORDER BY 
    amount DESC, order_id;