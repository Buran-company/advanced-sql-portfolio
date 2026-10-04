-- purpose: select products whose unit price exceeds the average price in their own category.

-- grain: one row per product whose unit price exceeds the average price per category

-- products with null in category or price are automatically excluded because AVG ignores NULL

SELECT
    p1.product_id,
    p1.product_name,
    p1.category,
    p1.unit_price,
    ROUND(cat_avg.avg_price, 2) AS category_avg_price,
    ROUND(p1.unit_price - cat_avg.avg_price, 2) AS price_diff_from_category_avg
FROM 
    products AS p1
CROSS JOIN LATERAL (
    SELECT AVG(p2.unit_price) AS avg_price
    FROM products AS p2
    WHERE p2.category = p1.category
) AS cat_avg
WHERE 
    p1.category IS NOT NULL
    AND p1.unit_price IS NOT NULL
    AND p1.unit_price > cat_avg.avg_price
ORDER BY 
    price_diff_from_category_avg DESC, p1.product_id;