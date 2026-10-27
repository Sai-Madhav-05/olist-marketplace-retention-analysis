-- 02_data_quality.sql
-- Business question: is the dataset complete and trustworthy enough for growth and delivery analysis?

SELECT 'customers' AS table_name, COUNT(*) AS total_rows,
       SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
       SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_unique_id
FROM customers;

SELECT 'orders' AS table_name, COUNT(*) AS total_rows,
       SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
       SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS missing_order_status,
       SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_ts,
       SUM(CASE WHEN order_status = 'delivered' AND order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS delivered_missing_delivery_date
FROM orders;

SELECT 'order_items' AS table_name, COUNT(*) AS total_rows,
       SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
       SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
       SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS missing_seller_id
FROM order_items;

-- orders with no items
SELECT o.order_id
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL;

-- delivered orders with impossible dates
SELECT COUNT(*) AS impossible_dates
FROM orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp > order_delivered_customer_date;

-- duplicate order IDs
SELECT order_id, COUNT(*) AS dup_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- duplicate customer IDs
SELECT customer_id, COUNT(*) AS dup_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- orders with no payment info
SELECT o.order_id
FROM orders o
LEFT JOIN order_payments op ON op.order_id = o.order_id
WHERE op.order_id IS NULL;
