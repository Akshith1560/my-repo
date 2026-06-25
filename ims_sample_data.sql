USE ims;

-- categories
INSERT INTO categories (name, description) VALUES
('Electronics','Electronic devices and parts'),
('Office Supplies','Stationery and office consumables'),
('Furniture','Office furniture'),
('Consumables','Packaging and disposable items'),
('Accessories','Device accessories');

-- suppliers
INSERT INTO suppliers (name, contact_name, phone, email, address) VALUES
('Acme Electronics','John Doe','+1-555-1111','john@acmee.com','123 Supplier St'),
('PaperPlus','Sara Smith','+1-555-2222','sara@paperplus.com','45 Paper Ave'),
('FurniCo','Mark Brown','+1-555-3333','mark@furnico.com','987 Wood Rd'),
('Global Parts','Lina Gomez','+1-555-4444','lina@globalparts.com','22 Parts Blvd'),
('PackCorp','Tom Lee','+1-555-5555','tom@packcorp.com','8 Packaging Ln');

-- warehouses
INSERT INTO warehouses (name, location, manager) VALUES
('Central Warehouse','City Center','Alice Manager'),
('North Depot','North District','Bob Keeper'),
('South Hub','South District','Cathy Lead');

-- products (20)
INSERT INTO products (sku, name, category_id, supplier_id, unit_price, reorder_level) VALUES
('ELEC-001','USB-C Cable 1m',1,1,3.50,50),
('ELEC-002','Wireless Mouse',1,1,12.99,20),
('ELEC-003','Keyboard Wired',1,1,18.00,15),
('OFF-001','A4 Printer Paper (500)',2,2,6.50,100),
('OFF-002','Stapler',2,2,4.20,30),
('FUR-001','Office Chair',3,3,89.99,5),
('FUR-002','Height Adjustable Desk',3,3,249.00,2),
('CON-001','Bubble Wrap Roll',4,5,15.00,20),
('CON-002','Packing Tape',4,5,2.50,100),
('ACC-001','Phone Case',5,4,5.00,60),
('ACC-002','Laptop Sleeve 13"',5,4,14.90,20),
('ELEC-004','Portable Charger 10000mAh',1,4,22.50,25),
('ELEC-005','HDMI Cable 2m',1,1,6.00,40),
('OFF-003','Highlighter Set',2,2,3.00,50),
('FUR-003','Filing Cabinet',3,3,120.00,3),
('CON-003','Disposable Gloves (100)',4,5,8.00,40),
('ACC-003','Wireless Earbuds',5,1,35.00,15),
('ELEC-006','External HDD 1TB',1,4,59.99,10),
('OFF-004','Desk Organizer',2,2,7.50,25),
('ACC-004','Monitor Stand',5,3,29.99,10);

-- stock_levels (product_id, warehouse_id, quantity) -- make up numbers
INSERT INTO stock_levels (product_id, warehouse_id, quantity) VALUES
(1,1,200),(1,2,50),(1,3,30),
(2,1,80),(2,2,30),(3,1,40),
(4,1,600),(4,2,200),(5,1,150),
(6,1,8),(6,2,2),(7,1,1),
(8,1,40),(9,1,500),(10,3,120),
(11,1,25),(12,1,30),(13,2,70),
(14,1,90),(15,3,4),(16,2,60),
(17,1,12),(18,1,7),(19,2,20),
(20,3,6);

-- customers
INSERT INTO customers (name, contact_name, phone, email, address) VALUES
('Acme Retail','Helen Clark','+1-555-1010','helen@acmeretail.com','10 Retail St'),
('OfficeWorld','Greg White','+1-555-2020','greg@officeworld.com','55 Work Ave'),
('TechShop','Rina Patel','+1-555-3030','rina@techshop.com','77 Tech Blvd'),
('Packers Inc','Sam Rogers','+1-555-4040','sam@packers.com','3 Commerce Rd'),
('SmallBiz Co','Linda Zhou','+1-555-5050','linda@smallbiz.com','12 Indie Ln');

-- sample purchase orders (3)
INSERT INTO purchase_orders (supplier_id, po_number, order_date, expected_date, status, total_amount) VALUES
(1,'PO-1001','2026-06-01','2026-06-07','received',350.00),
(2,'PO-1002','2026-06-03','2026-06-09','received',120.00),
(4,'PO-1003','2026-06-04','2026-06-12','open',500.00);

INSERT INTO purchase_order_items (po_id, product_id, warehouse_id, quantity_ordered, quantity_received, unit_cost) VALUES
(1,2,1,100,100,9.50),
(1,13,2,50,50,4.00),
(2,4,1,200,200,5.50),
(3,18,1,10,0,55.00),
(3,6,1,5,0,70.00);

-- sample sales orders (5)
INSERT INTO sales_orders (customer_id, so_number, order_date, ship_date, status, total_amount) VALUES
(1,'SO-2001','2026-06-10','2026-06-11','shipped',259.70),
(2,'SO-2002','2026-06-11',NULL,'processing',49.50),
(3,'SO-2003','2026-06-12','2026-06-13','shipped',149.99),
(4,'SO-2004','2026-06-12',NULL,'pending',32.50),
(5,'SO-2005','2026-06-13','2026-06-14','shipped',89.97);

INSERT INTO sales_order_items (so_id, product_id, warehouse_id, quantity, unit_price) VALUES
(1,12,1,2,22.50),
(1,2,1,10,12.99),
(2,10,3,3,5.00),
(3,18,1,1,59.99),
(3,11,1,2,14.90),
(4,9,1,13,2.50),
(5,3,1,1,18.00),
(5,17,1,2,35.00),
(2,14,1,3,3.00);

-- inventory_transactions (several)
INSERT INTO inventory_transactions (product_id, warehouse_id, txn_type, reference_id, quantity, unit_cost) VALUES
(2,1,'purchase_in','PO-1001',100,9.50),
(13,2,'purchase_in','PO-1001',50,4.00),
(4,1,'purchase_in','PO-1002',200,5.50),
(12,1,'sale_out','SO-2001',2,22.50),
(2,1,'sale_out','SO-2001',10,12.99),
(10,3,'sale_out','SO-2002',3,5.00);

-- app_users
INSERT INTO app_users (username, password_hash, full_name, email, role) VALUES
('admin','<bcrypt-hash>','System Admin','admin@example.com','admin'),
('clerk1','<bcrypt-hash>','Warehouse Clerk','clerk1@example.com','clerk'),
('mgr','<bcrypt-hash>','Warehouse Manager','mgr@example.com','manager');

-- audit_logs sample
INSERT INTO audit_logs (user_id, action, table_name, record_id, details) VALUES
(1,'created_product','products','1',JSON_OBJECT('sku','ELEC-001')),
(2,'received_po','purchase_orders','1',JSON_OBJECT('received_by','clerk1'));
