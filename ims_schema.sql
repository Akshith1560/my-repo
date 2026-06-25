-- Inventory Management System schema
-- Run in MySQL 5.7+ / 8.0
CREATE DATABASE IF NOT EXISTS ims
  CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
USE ims;

-- Categories
CREATE TABLE categories (
  category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (category_id),
  UNIQUE KEY ux_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Suppliers
CREATE TABLE suppliers (
  supplier_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  contact_name VARCHAR(120) NULL,
  phone VARCHAR(30) NULL,
  email VARCHAR(150) NULL,
  address TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (supplier_id),
  UNIQUE KEY ux_suppliers_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Warehouses
CREATE TABLE warehouses (
  warehouse_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  location VARCHAR(255) NULL,
  manager VARCHAR(120) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (warehouse_id),
  UNIQUE KEY ux_warehouses_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Products
CREATE TABLE products (
  product_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(50) NOT NULL,
  name VARCHAR(200) NOT NULL,
  category_id INT UNSIGNED NULL,
  supplier_id INT UNSIGNED NULL,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  reorder_level INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (product_id),
  UNIQUE KEY ux_products_sku (sku),
  KEY idx_products_category (category_id),
  KEY idx_products_supplier (supplier_id),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Stock levels per warehouse (current)
CREATE TABLE stock_levels (
  stock_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id INT UNSIGNED NOT NULL,
  warehouse_id INT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (stock_id),
  UNIQUE KEY ux_stock_product_warehouse (product_id, warehouse_id),
  KEY idx_stock_product (product_id),
  KEY idx_stock_warehouse (warehouse_id),
  CONSTRAINT fk_stock_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customers
CREATE TABLE customers (
  customer_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  contact_name VARCHAR(120) NULL,
  phone VARCHAR(30) NULL,
  email VARCHAR(150) NULL,
  address TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Purchase orders (incoming stock)
CREATE TABLE purchase_orders (
  po_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  supplier_id INT UNSIGNED NOT NULL,
  po_number VARCHAR(50) NOT NULL,
  order_date DATE NOT NULL,
  expected_date DATE NULL,
  status ENUM('open','partial','received','cancelled') NOT NULL DEFAULT 'open',
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (po_id),
  UNIQUE KEY ux_po_number (po_number),
  KEY idx_po_supplier (supplier_id),
  CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_order_items (
  poi_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  po_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  warehouse_id INT UNSIGNED NULL,
  quantity_ordered INT NOT NULL,
  quantity_received INT NOT NULL DEFAULT 0,
  unit_cost DECIMAL(12,2) NOT NULL,
  line_total DECIMAL(12,2) GENERATED ALWAYS AS (unit_cost * quantity_ordered) VIRTUAL,
  PRIMARY KEY (poi_id),
  KEY idx_poi_po (po_id),
  CONSTRAINT fk_poi_po FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
  CONSTRAINT fk_poi_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
  CONSTRAINT fk_poi_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sales orders (outgoing)
CREATE TABLE sales_orders (
  so_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id INT UNSIGNED NOT NULL,
  so_number VARCHAR(50) NOT NULL,
  order_date DATE NOT NULL,
  ship_date DATE NULL,
  status ENUM('pending','processing','shipped','cancelled') NOT NULL DEFAULT 'pending',
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (so_id),
  UNIQUE KEY ux_so_number (so_number),
  KEY idx_so_customer (customer_id),
  CONSTRAINT fk_so_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sales_order_items (
  soi_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  so_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  warehouse_id INT UNSIGNED NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  line_total DECIMAL(12,2) GENERATED ALWAYS AS (unit_price * quantity) VIRTUAL,
  PRIMARY KEY (soi_id),
  KEY idx_soi_so (so_id),
  CONSTRAINT fk_soi_so FOREIGN KEY (so_id) REFERENCES sales_orders(so_id) ON DELETE CASCADE,
  CONSTRAINT fk_soi_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
  CONSTRAINT fk_soi_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inventory transactions (audit trail of stock movements)
CREATE TABLE inventory_transactions (
  txn_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id INT UNSIGNED NOT NULL,
  warehouse_id INT UNSIGNED NOT NULL,
  txn_type ENUM('purchase_in','purchase_return','sale_out','sale_return','adjustment','transfer_in','transfer_out') NOT NULL,
  reference_id VARCHAR(100) NULL, -- e.g., PO number or SO number
  quantity INT NOT NULL,
  unit_cost DECIMAL(12,2) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (txn_id),
  KEY idx_txn_product (product_id),
  KEY idx_txn_warehouse (warehouse_id),
  CONSTRAINT fk_txn_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_txn_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- App users
CREATE TABLE app_users (
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(80) NOT NULL,
  password_hash CHAR(60) NOT NULL,
  full_name VARCHAR(150) NULL,
  email VARCHAR(150) NULL,
  role ENUM('admin','manager','clerk') NOT NULL DEFAULT 'clerk',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY ux_app_users_username (username),
  UNIQUE KEY ux_app_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Audit logs
CREATE TABLE audit_logs (
  log_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  action VARCHAR(150) NOT NULL,
  table_name VARCHAR(100) NULL,
  record_id VARCHAR(100) NULL,
  details JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  KEY idx_audit_user (user_id),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES app_users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Helpful view: product stock across warehouses
CREATE OR REPLACE VIEW product_stock_summary AS
SELECT p.product_id, p.sku, p.name,
  IFNULL(SUM(sl.quantity),0) AS total_quantity
FROM products p
LEFT JOIN stock_levels sl ON p.product_id = sl.product_id
GROUP BY p.product_id, p.sku, p.name;