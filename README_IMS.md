# Inventory Management System (IMS) — README and Instructions

This repository contains:
- ims_schema.sql — schema for IMS
- ims_sample_data.sql — sample data (approx 50 rows)
- ims_er.dot — Graphviz DOT for ER diagram
- PROJECT-03-INSTRUCTIONS.md — report template for students

Quick start — create DB and load sample data
1. Open MySQL client or MySQL Workbench SQL editor.
2. Run:
   SOURCE /path/to/ims_schema.sql;
   SOURCE /path/to/ims_sample_data.sql;
   -- or run ims_load.sql if you combined both.

Create a single-run combined script locally:
- Concatenate files:
  cat ims_schema.sql ims_sample_data.sql > ims_load.sql
  then run ims_load.sql.

Generate ER diagram PNG (Graphviz)
1. Install Graphviz (https://graphviz.org/download/).
2. From the directory containing ims_er.dot:
   dot -Tpng ims_er.dot -o ims_er.png

Import into MySQL Workbench and save .mwb
1. Open MySQL Workbench and connect.
2. Execute the SQL scripts as above to create `ims` database.
3. To create a model from the SQL:
   File -> Import -> Reverse Engineer MySQL Create Script...
   Select ims_schema.sql and follow wizard.
4. Arrange the diagram (Model -> Arrange -> Auto Layout).
5. Save model: File -> Save Model As... -> ims_model.mwb
6. Export diagram to PNG: File -> Export -> Export as PNG...

Indexes & performance notes
- Included indexes:
  - UNIQUE on sku, po_number, so_number, usernames.
  - Foreign key columns are indexed (explicit KEY declarations).
- Additional recommendations:
  - Add INDEX on products(name) if you search by name frequently:
    CREATE INDEX idx_products_name ON products(name);
  - For text search, consider FULLTEXT on `products(name)` (MySQL 5.6+ / InnoDB fulltext support).
  - For orders queries by date, add index on (order_date).
  - For inventory_transactions and audit_logs consider partitioning by created_at when very large.

Transactions & application logic
- Wrap each business operation that affects multiple tables (e.g., create sales order -> decrement stock -> insert inventory_transactions) in a DB transaction to maintain consistency.

Backup & recovery strategy
- Enable binary logging for PITR.
- Daily logical backup with mysqldump:
  mysqldump --single-transaction --routines --triggers --events -u root -p ims > ims_$(date +%F).sql
- For large DBs, use Percona XtraBackup or MySQL Enterprise Backup for physical backups.
- Keep offsite copies (S3 / cloud storage).
- Test restores periodically.

Sample queries (examples)
- Current stock for a product:
  SELECT * FROM product_stock_summary WHERE sku = 'ELEC-002';
- Reorder list:
  SELECT p.sku, p.name, IFNULL(SUM(sl.quantity),0) AS qty, p.reorder_level
  FROM products p
  LEFT JOIN stock_levels sl ON p.product_id = sl.product_id
  GROUP BY p.product_id
  HAVING qty <= p.reorder_level;
- Stock valuation:
  SELECT p.product_id, p.sku, p.name, IFNULL(SUM(sl.quantity),0) AS qty, p.unit_price,
    IFNULL(SUM(sl.quantity),0)*p.unit_price AS valuation
  FROM products p
  LEFT JOIN stock_levels sl ON p.product_id = sl.product_id
  GROUP BY p.product_id;

Next steps I can do for you (pick any)
- If you want, I will re-attempt to push to your repo once it exists or I have access.
- Generate longer sample datasets for stress testing (1000s of rows).
- Create a small Python/Flask or Node script to demonstrate basic CRUD operations.
- Produce the Project_03_Report_Template.docx locally and attach if you prefer me to generate and provide the file here (I can paste it as base64 if you want a binary download).
