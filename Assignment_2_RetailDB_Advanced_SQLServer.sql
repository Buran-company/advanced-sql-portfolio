/* ============================================================================
   ASSIGNMENT 2 RETAIL DATABASE FOR SQL SERVER
   Database: RetailDB_Advanced

   Supports Assignment 2: Advanced SQL Portfolio
   Topics: joins, subqueries, CTEs, CASE, conditional aggregation,
   ranking, running totals, and moving averages.

   Run this complete script in SQL Server Management Studio.

   WARNING: This script drops and recreates RetailDB_Advanced.
============================================================================ */

USE master;
GO

IF DB_ID('RetailDB_Advanced') IS NOT NULL
BEGIN
    ALTER DATABASE RetailDB_Advanced
        SET SINGLE_USER
        WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RetailDB_Advanced;
END;
GO

CREATE DATABASE RetailDB_Advanced;
GO

USE RetailDB_Advanced;
GO

SET NOCOUNT ON;
GO

/* ============================================================================
   TABLE 1: customers
   Grain: one row per customer.
============================================================================ */

CREATE TABLE dbo.customers
(
    customer_id   INT          NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    segment       VARCHAR(20)  NOT NULL,
    region        VARCHAR(20)  NOT NULL,
    signup_date   DATE         NOT NULL,
    status        VARCHAR(20)  NOT NULL,

    CONSTRAINT PK_customers PRIMARY KEY (customer_id),
    CONSTRAINT CK_customers_segment
        CHECK (segment IN ('Consumer', 'SMB', 'Enterprise')),
    CONSTRAINT CK_customers_region
        CHECK (region IN ('North', 'South', 'East', 'West')),
    CONSTRAINT CK_customers_status
        CHECK (status IN ('Active', 'Inactive', 'Prospect'))
);
GO

;WITH numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 180
)
INSERT INTO dbo.customers
(
    customer_id,
    customer_name,
    segment,
    region,
    signup_date,
    status
)
SELECT
    n,
    CONCAT('Customer ', RIGHT(CONCAT('000', n), 3)),
    CASE
        WHEN n % 5 = 0 THEN 'Enterprise'
        WHEN n % 3 = 0 THEN 'SMB'
        ELSE 'Consumer'
    END,
    CASE n % 4
        WHEN 0 THEN 'West'
        WHEN 1 THEN 'North'
        WHEN 2 THEN 'South'
        ELSE 'East'
    END,
    DATEADD(DAY, -(300 + n * 6), CAST('2025-01-01' AS DATE)),
    CASE
        WHEN n % 13 = 0 THEN 'Inactive'
        WHEN n > 160 THEN 'Prospect'
        ELSE 'Active'
    END
FROM numbers
OPTION (MAXRECURSION 0);
GO

/* ============================================================================
   TABLE 2: addresses
   Grain: one row per stored customer address.

   Customers deliberately have between one and three addresses. This supports
   the one-to-many join multiplication investigation in Assignment 2.
============================================================================ */

CREATE TABLE dbo.addresses
(
    address_id  INT          NOT NULL,
    customer_id INT          NOT NULL,
    city        VARCHAR(60)  NOT NULL,
    country     VARCHAR(60)  NOT NULL,
    is_current  BIT          NOT NULL,
    updated_at  DATETIME2(0) NOT NULL,

    CONSTRAINT PK_addresses PRIMARY KEY (address_id),
    CONSTRAINT FK_addresses_customer
        FOREIGN KEY (customer_id)
        REFERENCES dbo.customers (customer_id)
        ON DELETE NO ACTION,
    CONSTRAINT UQ_addresses_customer_address
        UNIQUE (customer_id, address_id)
);
GO

INSERT INTO dbo.addresses
(
    address_id,
    customer_id,
    city,
    country,
    is_current,
    updated_at
)
SELECT
    c.customer_id * 10 + a.address_number,
    c.customer_id,
    CASE (c.customer_id + a.address_number) % 8
        WHEN 0 THEN 'London'
        WHEN 1 THEN 'Berlin'
        WHEN 2 THEN 'Bucharest'
        WHEN 3 THEN 'Istanbul'
        WHEN 4 THEN 'Madrid'
        WHEN 5 THEN 'Paris'
        WHEN 6 THEN 'Rome'
        ELSE 'Amsterdam'
    END,
    CASE (c.customer_id + a.address_number) % 8
        WHEN 0 THEN 'United Kingdom'
        WHEN 1 THEN 'Germany'
        WHEN 2 THEN 'Romania'
        WHEN 3 THEN 'Turkey'
        WHEN 4 THEN 'Spain'
        WHEN 5 THEN 'France'
        WHEN 6 THEN 'Italy'
        ELSE 'Netherlands'
    END,
    CASE WHEN a.address_number = 1 THEN 1 ELSE 0 END,
    DATEADD(
        DAY,
        -(c.customer_id + a.address_number * 20),
        CAST('2026-12-31T12:00:00' AS DATETIME2(0))
    )
FROM dbo.customers AS c
CROSS APPLY
(
    SELECT 1 AS address_number
    UNION ALL
    SELECT 2 WHERE c.customer_id % 3 <> 0
    UNION ALL
    SELECT 3 WHERE c.customer_id % 4 = 0
) AS a;
GO

CREATE INDEX IX_addresses_customer_id
    ON dbo.addresses (customer_id);
GO

/* ============================================================================
   TABLE 3: products
   Grain: one row per product.

   unit_price is included because Assignment 2 asks students to compare a
   product's unit price with the average price in its category.
============================================================================ */

CREATE TABLE dbo.products
(
    product_id   INT            NOT NULL,
    product_name VARCHAR(100)   NOT NULL,
    category     VARCHAR(40)    NULL,
    supplier_id  INT            NULL,
    unit_cost    DECIMAL(10, 2) NULL,
    unit_price   DECIMAL(10, 2) NULL,

    CONSTRAINT PK_products PRIMARY KEY (product_id),
    CONSTRAINT CK_products_unit_cost
        CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CONSTRAINT CK_products_unit_price
        CHECK (unit_price IS NULL OR unit_price >= 0)
);
GO

INSERT INTO dbo.products
(
    product_id,
    product_name,
    category,
    supplier_id,
    unit_cost,
    unit_price
)
VALUES
    (1001, 'Smartphone Pro',       'Electronics', 501, 520.00, 899.99),
    (1002, 'Smartphone Lite',      'Electronics', 501, 240.00, 449.99),
    (1003, 'Smartwatch',           'Electronics', 502, 120.00, 249.99),
    (1004, 'Wireless Speaker',     'Electronics', 502,  65.00, 129.99),
    (1005, 'Large Monitor',        'Hardware',    503, 180.00, 329.99),
    (1006, 'Mechanical Keyboard',  'Hardware',    503,  55.00, 109.99),
    (1007, 'Wireless Mouse',       'Hardware',    504,  22.00,  49.99),
    (1008, 'Docking Station',      'Hardware',    504,  80.00, 159.99),
    (1009, 'Analytics Pro',        'Software',    505,  40.00, 249.99),
    (1010, 'Office Suite',         'Software',    505,  25.00, 149.99),
    (1011, 'Security Suite',       'Software',    506,  18.00, 119.99),
    (1012, 'Design Studio',        'Software',    506,  55.00, 299.99),
    (1013, 'Ergonomic Chair',      'Office',      507, 140.00, 279.99),
    (1014, 'Standing Desk',        'Office',      507, 230.00, 499.99),
    (1015, 'Desk Lamp',            'Office',      508,  24.00,  59.99),
    (1016, 'Storage Cabinet',      'Office',      508,  95.00, 189.99),
    (1017, 'Coffee Maker',         'Home',        509,  48.00,  99.99),
    (1018, 'Air Purifier',         'Home',        509, 110.00, 229.99),
    (1019, 'Storage Box',          'Home',        510,  12.00,  29.99),
    (1020, 'Sofa Cover',           'Home',        510,  18.00,  44.99),
    (1021, 'Laptop Sleeve',        'Accessories', 511,  10.00,  24.99),
    (1022, 'Laptop Stand',         'Accessories', 511,  17.00,  39.99),
    (1023, 'USB Cable',            'Accessories', 512,   4.00,  14.99),
    (1024, 'Travel Adapter',       'Accessories', 512,  11.00,  29.99),
    (1025, 'Unclassified Sample',  NULL,          NULL,  NULL,   NULL);
GO

/* ============================================================================
   TABLE 4: orders
   Grain: one row per order.

   The data includes five deliberately unmatched customer IDs and a controlled
   set of NULL or invalid shipping-address IDs for audit exercises.
============================================================================ */

CREATE TABLE dbo.orders
(
    order_id            INT            NOT NULL,
    customer_id         INT            NOT NULL,
    order_date          DATE           NOT NULL,
    status              VARCHAR(20)    NOT NULL,
    amount              DECIMAL(14, 2) NOT NULL
        CONSTRAINT DF_orders_amount DEFAULT (0),
    shipping_address_id INT            NULL,

    CONSTRAINT PK_orders PRIMARY KEY (order_id),
    CONSTRAINT CK_orders_status
        CHECK (status IN ('Completed', 'Pending', 'Cancelled')),
    CONSTRAINT CK_orders_amount CHECK (amount >= 0)
);
GO

;WITH numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 720
)
INSERT INTO dbo.orders
(
    order_id,
    customer_id,
    order_date,
    status,
    amount,
    shipping_address_id
)
SELECT
    n,
    ((n - 1) % 160) + 1,
    DATEADD(DAY, n - 1, CAST('2025-01-01' AS DATE)),
    CASE
        WHEN n % 10 = 0 THEN 'Cancelled'
        WHEN n % 6 = 0 THEN 'Pending'
        ELSE 'Completed'
    END,
    0,
    CASE
        WHEN n % 29 = 0 THEN NULL
        WHEN n % 37 = 0 THEN 800000 + n
        ELSE (((n - 1) % 160) + 1) * 10 + 1
    END
FROM numbers
OPTION (MAXRECURSION 0);
GO

INSERT INTO dbo.orders
(
    order_id,
    customer_id,
    order_date,
    status,
    amount,
    shipping_address_id
)
VALUES
    (721, 9001, '2026-12-22', 'Completed', 0, NULL),
    (722, 9002, '2026-12-23', 'Completed', 0, NULL),
    (723, 9003, '2026-12-24', 'Pending',   0, 899901),
    (724, 9004, '2026-12-25', 'Cancelled', 0, 899902),
    (725, 9005, '2026-12-26', 'Completed', 0, NULL);
GO

CREATE INDEX IX_orders_customer_id
    ON dbo.orders (customer_id);
GO

CREATE INDEX IX_orders_order_date
    ON dbo.orders (order_date);
GO

CREATE INDEX IX_orders_shipping_address_id
    ON dbo.orders (shipping_address_id);
GO

/* ============================================================================
   TABLE 5: order_items
   Grain: one row per order line.
   Composite key: order_id and line_number.
============================================================================ */

CREATE TABLE dbo.order_items
(
    order_id     INT            NOT NULL,
    line_number  INT            NOT NULL,
    product_id   INT            NOT NULL,
    quantity     INT            NOT NULL,
    unit_price   DECIMAL(10, 2) NOT NULL,
    discount_pct DECIMAL(5, 2)  NULL,

    CONSTRAINT PK_order_items PRIMARY KEY (order_id, line_number),
    CONSTRAINT FK_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES dbo.orders (order_id)
        ON DELETE NO ACTION,
    CONSTRAINT FK_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES dbo.products (product_id)
        ON DELETE NO ACTION,
    CONSTRAINT CK_order_items_line_number CHECK (line_number > 0),
    CONSTRAINT CK_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT CK_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT CK_order_items_discount_pct
        CHECK (discount_pct IS NULL OR discount_pct BETWEEN 0 AND 100)
);
GO

INSERT INTO dbo.order_items
(
    order_id,
    line_number,
    product_id,
    quantity,
    unit_price,
    discount_pct
)
SELECT
    o.order_id,
    line_data.line_number,
    p.product_id,
    1 + ((o.order_id + line_data.line_number) % 5),
    p.unit_price,
    CASE
        WHEN (o.order_id * 3 + line_data.line_number) % 11 = 0 THEN NULL
        WHEN (o.order_id + line_data.line_number) % 5 = 0 THEN 20.00
        WHEN (o.order_id + line_data.line_number) % 4 = 0 THEN 15.00
        WHEN (o.order_id + line_data.line_number) % 3 = 0 THEN 10.00
        ELSE 5.00
    END
FROM dbo.orders AS o
CROSS JOIN
(
    VALUES (1), (2), (3)
) AS line_data (line_number)
JOIN dbo.products AS p
    ON p.product_id = CASE
        WHEN o.customer_id BETWEEN 1 AND 8 THEN 1023
        ELSE 1001 + ((o.order_id + line_data.line_number - 2) % 24)
    END;
GO

CREATE INDEX IX_order_items_product_id
    ON dbo.order_items (product_id);
GO

/* Calculate each order amount from its discounted order lines. */

UPDATE o
SET o.amount = totals.order_amount
FROM dbo.orders AS o
JOIN
(
    SELECT
        order_id,
        CAST(
            SUM(
                quantity * unit_price
                * (1 - COALESCE(discount_pct, 0) / 100.0)
            )
            AS DECIMAL(14, 2)
        ) AS order_amount
    FROM dbo.order_items
    GROUP BY order_id
) AS totals
    ON totals.order_id = o.order_id;
GO

/* Add logical foreign keys without validating the deliberate audit exceptions.
   New rows must still satisfy these relationships. */

ALTER TABLE dbo.orders WITH NOCHECK
ADD CONSTRAINT FK_orders_customer
    FOREIGN KEY (customer_id)
    REFERENCES dbo.customers (customer_id);
GO

ALTER TABLE dbo.orders WITH NOCHECK
ADD CONSTRAINT FK_orders_shipping_address
    FOREIGN KEY (shipping_address_id)
    REFERENCES dbo.addresses (address_id);
GO

/* ============================================================================
   TABLE 6: daily_sales
   Grain: one row per sales date and customer region.

   daily_sales contains completed-order metrics. It supports staged monthly
   trend and moving-average analysis without exposing order-line grain.
============================================================================ */

CREATE TABLE dbo.daily_sales
(
    sales_date    DATE           NOT NULL,
    region        VARCHAR(20)    NOT NULL,
    daily_revenue DECIMAL(16, 2) NOT NULL,
    order_count   INT            NOT NULL,

    CONSTRAINT PK_daily_sales PRIMARY KEY (sales_date, region),
    CONSTRAINT CK_daily_sales_revenue CHECK (daily_revenue >= 0),
    CONSTRAINT CK_daily_sales_order_count CHECK (order_count >= 0)
);
GO

INSERT INTO dbo.daily_sales
(
    sales_date,
    region,
    daily_revenue,
    order_count
)
SELECT
    o.order_date,
    COALESCE(c.region, 'Unmatched') AS region,
    CAST(SUM(o.amount) AS DECIMAL(16, 2)) AS daily_revenue,
    COUNT(*) AS order_count
FROM dbo.orders AS o
LEFT JOIN dbo.customers AS c
    ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY
    o.order_date,
    COALESCE(c.region, 'Unmatched');
GO

CREATE INDEX IX_daily_sales_date
    ON dbo.daily_sales (sales_date);
GO

/* ============================================================================
   VALIDATION CHECKS
============================================================================ */

IF (SELECT COUNT(*) FROM dbo.customers) <> 180
    THROW 52000, 'Validation failed: customers must contain 180 rows.', 1;

IF (SELECT COUNT(*) FROM dbo.products) <> 25
    THROW 52001, 'Validation failed: products must contain 25 rows.', 1;

IF (SELECT COUNT(*) FROM dbo.orders) <> 725
    THROW 52002, 'Validation failed: orders must contain 725 rows.', 1;

IF (SELECT COUNT(*) FROM dbo.order_items) <> 2175
    THROW 52003, 'Validation failed: order_items must contain 2175 rows.', 1;

IF
(
    SELECT COUNT(*)
    FROM dbo.orders AS o
    LEFT JOIN dbo.customers AS c
        ON c.customer_id = o.customer_id
    WHERE c.customer_id IS NULL
) <> 5
    THROW 52004, 'Validation failed: five unmatched orders are required.', 1;

IF NOT EXISTS
(
    SELECT customer_id
    FROM dbo.addresses
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)
    THROW 52005, 'Validation failed: multiple addresses per customer are required.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.orders AS o
    LEFT JOIN dbo.addresses AS a
        ON a.address_id = o.shipping_address_id
    WHERE a.address_id IS NULL
)
    THROW 52006, 'Validation failed: missing shipping-address matches are required.', 1;

IF
(
    SELECT COUNT(*)
    FROM dbo.customers AS c
    LEFT JOIN dbo.orders AS o
        ON o.customer_id = c.customer_id
    WHERE o.order_id IS NULL
) < 20
    THROW 52007, 'Validation failed: customers with no orders are required.', 1;

IF
(
    SELECT COUNT(DISTINCT DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1))
    FROM dbo.orders
    WHERE status = 'Completed'
) < 20
    THROW 52008, 'Validation failed: at least 20 completed-order months are required.', 1;

IF
(
    SELECT COUNT(DISTINCT customer_value_category)
    FROM
    (
        SELECT
            CASE
                WHEN COALESCE(m.completed_order_count, 0) = 0 THEN 'No Orders'
                WHEN m.completed_spend >= 10000 THEN 'Premium'
                WHEN m.completed_spend >= 5000 THEN 'High'
                WHEN m.completed_spend >= 1000 THEN 'Developing'
                ELSE 'Standard'
            END AS customer_value_category
        FROM dbo.customers AS c
        LEFT JOIN
        (
            SELECT
                customer_id,
                COUNT(*) AS completed_order_count,
                SUM(amount) AS completed_spend
            FROM dbo.orders
            WHERE status = 'Completed'
            GROUP BY customer_id
        ) AS m
            ON m.customer_id = c.customer_id
    ) AS categories
) <> 5
    THROW 52009, 'Validation failed: all five customer value categories are required.', 1;
GO

/* ============================================================================
   SQL SERVER DIALECT REFERENCE

   Assignment 2 permits approved dialect equivalents. In SQL Server use:

   PostgreSQL                            SQL Server
   ------------------------------------  --------------------------------------
   DATE '2026-01-01'                    CAST('2026-01-01' AS DATE)
   DATE_TRUNC('month', order_date)      DATEFROMPARTS(YEAR(order_date),
                                                       MONTH(order_date), 1)
   CURRENT_DATE                         CAST(GETDATE() AS DATE)
   current_date - another_date          DATEDIFF(DAY, another_date,
                                                 CAST(GETDATE() AS DATE))
   LIMIT 10                             SELECT TOP (10) ...

   Start every assignment query with:

       USE RetailDB_Advanced;
============================================================================ */

SELECT
    (SELECT COUNT(*) FROM dbo.customers) AS customer_rows,
    (SELECT COUNT(*) FROM dbo.addresses) AS address_rows,
    (SELECT COUNT(*) FROM dbo.products) AS product_rows,
    (SELECT COUNT(*) FROM dbo.orders) AS order_rows,
    (SELECT COUNT(*) FROM dbo.order_items) AS order_item_rows,
    (SELECT COUNT(*) FROM dbo.daily_sales) AS daily_sales_rows;
GO

PRINT 'RetailDB_Advanced was created and validated successfully.';
GO
