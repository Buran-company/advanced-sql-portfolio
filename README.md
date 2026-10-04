# advanced-sql-portfolio

Aleksei Mukhin, PostgreSQL, Assignment_2_RetailDB_Advanced_SQLServer.sql

Question 3 Interpretation required:

Customers with multiple addresses (up to 3) are causing significant multiplication of rows when we join the orders directly by customer_id, because cartesian product is combining each order with each address. It demonstrates why joining the orders with customers' addresses without filter by shipping_address_id causes invalid metrics or invalid aggregations.

Question 6 Interpretation required:

Both "in" and "exists" help to isolate positions bought by corporate customers, preventing duplication using "distinct". This filtration helps merchandisers identify product preferences, it is especially useful for premium segment.

Question 9 Interpretation required:

Using "left join" and "coalesce" feature table both contains inactive customers and calculates the prescription of interaction for active customers. It allows customer service departments to purposefully work with outgoing customers and to encourage valuable customers. 

Question 12 Interpretation required:

KPI shows stable level of accomplishment (~70-74%) among the regions, and also highlights the differences in orders amount and average check. This operational summary allows regional managers to identify where logistical delays or spikes in cancellations affect revenue.

Question 14 Interpretation required:

The cumulative spending window function tracks the growth of customer value over time, pinpointing when key thresholds are reached. This trajectory analysis is necessary to identify loyal customers and apply loyalty measures.

Question 15 Interpretation required:

The three-month moving average smooths out short-term volatility. It identifies revenue macro trends and suppresses early periods where fewer than three observations. This smoothing method helps financial analysts to separate seasonal noise from structural business growth.