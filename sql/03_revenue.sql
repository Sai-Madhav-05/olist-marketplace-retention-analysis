-- 03_revenue.sql
-- Business question: how much revenue did the marketplace generate each month, and which categories and states drove it?

WITH monthly_revenue AS (
  SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month_key,
    SUM(oi.price) AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
  month_key,
  revenue,
  ROUND(
    100.0 * (revenue - LAG(revenue) OVER (ORDER BY month_key)) / NULLIF(LAG(revenue) OVER (ORDER BY month_key), 0),
    2
  ) AS mom_pct
FROM monthly_revenue
ORDER BY month_key;

-- Business question: which product categories created the most revenue?
SELECT
  ct.product_category_name_english AS category,
  SUM(oi.price) AS category_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation ct
  ON ct.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY category_revenue DESC
LIMIT 10;

-- Business question: which customer states contributed most to revenue?
SELECT
  c.customer_state AS state,
  SUM(oi.price) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;
