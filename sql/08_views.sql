-- 08_views.sql
-- Business question: what is the clean fact table for Power BI?

CREATE OR REPLACE VIEW vw_order_facts AS
SELECT
  o.order_id,
  o.customer_id,
  cu.customer_unique_id,
  oi.product_id,
  p.product_category_name,
  ct.product_category_name_english AS category_name,
  s.seller_id,
  s.seller_state,
  cu.customer_state,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS days_vs_estimate,
  CASE
    WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
    ELSE 0
  END AS is_late,
  oi.price,
  oi.freight_value,
  COALESCE(op.payment_value, oi.price + oi.freight_value) AS order_value,
  r.review_score,
  CASE
    WHEN o.order_purchase_timestamp = (
      SELECT MIN(o2.order_purchase_timestamp)
      FROM orders o2
      WHERE o2.customer_id = o.customer_id
    ) THEN 1 ELSE 0
  END AS first_order_flag
FROM orders o
JOIN customers cu ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation ct ON ct.product_category_name = p.product_category_name
LEFT JOIN sellers s ON s.seller_id = oi.seller_id
LEFT JOIN order_reviews r ON r.order_id = o.order_id
LEFT JOIN order_payments op ON op.order_id = o.order_id
WHERE o.order_status = 'delivered';
