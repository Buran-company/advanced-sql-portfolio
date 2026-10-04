-- purpose: display every completed order with the customer’s cumulative completed spend

-- grain: one row per completed order

SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    ROUND(
        SUM(amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date ASC, order_id ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS running_spend
FROM 
    orders
WHERE 
    status = 'Completed'
ORDER BY 
    customer_id, order_date, order_id;