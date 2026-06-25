-- Sample reports and queries for IMS

-- 1) Current stock per product (summary)
SELECT p.product_id, p.sku, p.name, IFNULL(SUM(sl.quantity),0) AS qty_on_hand
FROM products p
LEFT JOIN stock_levels sl ON p.product_id = sl.product_id
GROUP BY p.product_id, p.sku, p.name
ORDER BY qty_on_hand ASC;

-- 2) Reorder list (items at or below reorder level)
SELECT p.product_id, p.sku, p.name, IFNULL(SUM(sl.quantity),0) AS qty_on_hand, p.reorder_level
FROM products p
LEFT JOIN stock_levels sl ON p.product_id = sl.product_id
GROUP BY p.product_id
HAVING qty_on_hand <= p.reorder_level
ORDER BY qty_on_hand ASC;

-- 3) Sales by product (last 30 days)
SELECT p.product_id, p.sku, p.name, SUM(soi.quantity) AS qty_sold, SUM(soi.line_total) AS revenue
FROM sales_order_items soi
JOIN sales_orders so ON soi.so_id = so.so_id
JOIN products p ON soi.product_id = p.product_id
WHERE so.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.product_id
ORDER BY qty_sold DESC;

-- 4) Stock valuation
SELECT p.product_id, p.sku, p.name, IFNULL(SUM(sl.quantity),0) AS qty, p.unit_price, IFNULL(SUM(sl.quantity),0)*p.unit_price AS valuation
FROM products p
LEFT JOIN stock_levels sl ON p.product_id = sl.product_id
GROUP BY p.product_id;
