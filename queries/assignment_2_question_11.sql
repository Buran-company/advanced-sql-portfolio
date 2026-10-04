-- purpose: classify customers by categories based on wages

-- grain: one row per category

WITH completed_orders AS (
    SELECT
        customer_id,
        amount
    FROM 
        orders
    WHERE 
        status = 'Completed'
),
customer_spend AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(o.amount), 0.00) AS completed_spend,
        COUNT(o.amount) AS order_count
    FROM 
        customers AS c
    LEFT JOIN completed_orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY 
        c.customer_id
),
categorized_customers AS (
    SELECT
        customer_id,
        completed_spend,
        CASE
            WHEN order_count = 0 THEN 'No Orders'
            WHEN completed_spend >= 10000.00 THEN 'Premium'
            WHEN completed_spend >= 5000.00 THEN 'High'
            WHEN completed_spend >= 1000.00 THEN 'Developing'
            ELSE 'Standard'
        END AS customer_value_category
    FROM 
        customer_spend
)
SELECT
    customer_value_category,
    COUNT(*) AS customer_count
FROM 
    categorized_customers
GROUP BY 
    customer_value_category
ORDER BY 
    CASE customer_value_category
        WHEN 'Premium' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Developing' THEN 3
        WHEN 'Standard' THEN 4
        WHEN 'No Orders' THEN 5
    END;