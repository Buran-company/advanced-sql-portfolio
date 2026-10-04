-- purpose: create monthly completed revenue and a trailing three-month moving average.

-- grain: one row per month

-- frame ROWS considers only the physical number of preceding lines despite of time gaps.
-- if some month does not have completed orders, so it fall from aggregation, then frame ROWS will capture more old month instead of recognizing the missing period as zero.

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        SUM(amount) AS monthly_rev
    FROM 
        orders
    WHERE 
        status = 'Completed'
    GROUP BY 
        DATE_TRUNC('month', order_date)
)
SELECT
    order_month,
    ROUND(monthly_rev, 2) AS monthly_revenue,
    COUNT(monthly_rev) OVER (
        ORDER BY 
            order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS frame_observation_count,
    CASE
        WHEN COUNT(monthly_rev) OVER (
            ORDER BY 
                order_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) < 3 THEN NULL
        ELSE ROUND(
            AVG(monthly_rev) OVER (
                ORDER BY 
                    order_month
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ),
            2
        )
    END AS trailing_3m_avg_revenue
FROM 
    monthly_revenue
ORDER BY 
    order_month;