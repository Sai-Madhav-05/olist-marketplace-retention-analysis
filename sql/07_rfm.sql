-- 07_rfm.sql
-- Business question: how can we segment customers by value and engagement?

WITH customer_metrics AS (
  SELECT
    cu.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(oi.price) AS monetary
  FROM orders o
  JOIN customers cu ON cu.customer_id = o.customer_id
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY cu.customer_unique_id
),
rfm_scores AS (
  SELECT
    customer_unique_id,
    DATEDIFF(CURDATE(), last_order_date) AS recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY DATEDIFF(CURDATE(), last_order_date) DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
  FROM customer_metrics
)
SELECT
  customer_unique_id,
  recency_days,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  CONCAT(r_score, f_score, m_score) AS rfm_code
FROM rfm_scores
ORDER BY r_score, f_score, m_score;
