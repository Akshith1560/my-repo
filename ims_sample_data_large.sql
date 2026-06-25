-- Large sample data for IMS (ims_sample_data_large.sql)
-- Generated: products=500, customers=500, purchase_orders=2000, sales_orders=2000
USE ims;

-- categories (assume existing)
-- suppliers (assume existing)
-- warehouses (assume existing)

-- PRODUCTS (500)
INSERT INTO products (sku, name, category_id, supplier_id, unit_price, reorder_level) VALUES
