# advanced-sql-portfolio

Aleksei Mukhin, PostgreSQL, Assignment_2_RetailDB_Advanced_SQLServer.sql

Question 3 Interpretation required:

Customers with multiple addresses (up to 3) are causing significant multiplication of rows when we join the orders directly by customer_id, because cartesian product is combining each order with each address. It demonstrates why joining the orders with customers' addresses without filter by shipping_address_id causes invalid metrics or invalid aggregations.

Question 6 Interpretation required:

Both "in" and "exists" help to isolate positions bought by corporate customers, preventing duplication using "distinct". This filtration helps merchandisers identify product preferences, it is especially useful for premium segment.