-- 06_reviews.sql
-- Business question: do late orders receive lower review scores?

SELECT
  CASE
    WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late'
    ELSE 'on_time'
  END AS delivery_status,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(r.review_score) AS review_count
FROM orders o
LEFT JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY CASE
  WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late'
  ELSE 'on_time'
END;

-- Business question: which categories have lower average review scores?
SELECT
  ct.product_category_name_english AS category,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(r.review_score) AS review_count
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation ct ON ct.product_category_name = p.product_category_name
LEFT JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY avg_review_score ASC;
