-- 04_retention.sql
-- Business question: what share of customers buy more than once, and how quickly do they come back?

-- repeat customer percentage
WITH customer_orders AS (
  SELECT
    cu.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
  FROM orders o
  JOIN customers cu USING (customer_id)
  WHERE o.order_status = 'delivered'
  GROUP BY cu.customer_unique_id
)
SELECT
  ROUND(100.0 * SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_customer_pct
FROM customer_orders;

-- Business question: how much time passes between a customer's first and second order?
WITH first_order AS (
  SELECT
    cu.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase_date
  FROM orders o
  JOIN customers cu USING (customer_id)
  GROUP BY cu.customer_unique_id
)
SELECT
  ROUND(AVG(DATEDIFF(second_purchase_date, first_purchase_date)), 2) AS avg_days_to_second_order
FROM (
  SELECT
    f.customer_unique_id,
    f.first_purchase_date,
    (
      SELECT MIN(o2.order_purchase_timestamp)
      FROM orders o2
      JOIN customers cu2 ON cu2.customer_id = o2.customer_id
      WHERE cu2.customer_unique_id = f.customer_unique_id
        AND o2.order_purchase_timestamp > f.first_purchase_date
    ) AS second_purchase_date
  FROM first_order f
) x
WHERE second_purchase_date IS NOT NULL;
