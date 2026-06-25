"""
generate_large_data.py

Generates a large sample data SQL file for the IMS schema.
Usage: python generate_large_data.py --out ims_sample_data_large.sql --products 200 --customers 200 --pos 2000 --sos 2000

This script outputs SQL statements to create categories, suppliers, warehouses, products, stock_levels,
customers, purchase_orders + items, sales_orders + items, and inventory_transactions.
"""
import argparse
import random
import datetime

CATEGORIES = [
    ('Electronics','Electronic devices and parts'),
    ('Office Supplies','Stationery and office consumables'),
    ('Furniture','Office furniture'),
    ('Consumables','Packaging and disposable items'),
    ('Accessories','Device accessories')
]

SUPPLIERS = [
    ('Acme Electronics','John Doe','+1-555-1111','john@acmee.com','123 Supplier St'),
    ('PaperPlus','Sara Smith','+1-555-2222','sara@paperplus.com','45 Paper Ave'),
    ('FurniCo','Mark Brown','+1-555-3333','mark@furnico.com','987 Wood Rd'),
    ('Global Parts','Lina Gomez','+1-555-4444','lina@globalparts.com','22 Parts Blvd'),
    ('PackCorp','Tom Lee','+1-555-5555','tom@packcorp.com','8 Packaging Ln')
]

WAREHOUSES = [
    ('Central Warehouse','City Center','Alice Manager'),
    ('North Depot','North District','Bob Keeper'),
    ('South Hub','South District','Cathy Lead')
]

PRODUCT_NAME_TOKENS = ['USB','Cable','Wireless','Mouse','Keyboard','Paper','Chair','Desk','Wrap','Tape','Case','Sleeve','Charger','HDMI','Highlighter','Cabinet','Gloves','Earbuds','HDD','Organizer']


def sql_escape(s):
    return s.replace("'","''")


def gen_products(n, start_id=1, num_categories=5, num_suppliers=5):
    products = []
    for i in range(n):
        sku = f"PRD-{start_id+i:05d}"
        name = f"{random.choice(PRODUCT_NAME_TOKENS)} {random.randint(1,999)}"
        category_id = random.randint(1, num_categories)
        supplier_id = random.randint(1, num_suppliers)
        unit_price = round(random.uniform(1.0, 500.0),2)
        reorder = random.randint(0,100)
        products.append((sku, name, category_id, supplier_id, unit_price, reorder))
    return products


def generate(args):
    out = []
    out.append("USE ims;\n\n")
    # categories
    out.append("-- categories\n")
    for c in CATEGORIES:
        out.append(f"INSERT INTO categories (name, description) VALUES ('{sql_escape(c[0])}', '{sql_escape(c[1])}');\n")
    out.append("\n-- suppliers\n")
    for s in SUPPLIERS:
        out.append(f"INSERT INTO suppliers (name, contact_name, phone, email, address) VALUES ('{sql_escape(s[0])}', '{sql_escape(s[1])}', '{sql_escape(s[2])}', '{sql_escape(s[3])}', '{sql_escape(s[4])}');\n")
    out.append("\n-- warehouses\n")
    for w in WAREHOUSES:
        out.append(f"INSERT INTO warehouses (name, location, manager) VALUES ('{sql_escape(w[0])}', '{sql_escape(w[1])}', '{sql_escape(w[2])}');\n")

    # products
    out.append("\n-- products\n")
    products = gen_products(args.products, start_id=1, num_categories=len(CATEGORIES), num_suppliers=len(SUPPLIERS))
    for p in products:
        out.append("INSERT INTO products (sku, name, category_id, supplier_id, unit_price, reorder_level) VALUES ")
        out.append(f"('{sql_escape(p[0])}','{sql_escape(p[1])}',{p[2]},{p[3]},{p[4]},{p[5]});\n")

    # stock levels across warehouses
    out.append("\n-- stock_levels\n")
    pid = 1
    for _ in range(len(products)):
        for wid in range(1, len(WAREHOUSES)+1):
            qty = random.randint(0,500)
            out.append(f"INSERT INTO stock_levels (product_id, warehouse_id, quantity) VALUES ({pid},{wid},{qty});\n")
        pid += 1

    # customers
    out.append("\n-- customers\n")
    for i in range(args.customers):
        name = f"Customer {i+1}"
        contact = f"Contact {i+1}"
        phone = f"+1-800-{random.randint(1000,9999)}"
        email = f"customer{i+1}@example.com"
        out.append(f"INSERT INTO customers (name, contact_name, phone, email, address) VALUES ('{sql_escape(name)}','{sql_escape(contact)}','{sql_escape(phone)}','{sql_escape(email)}','Address {i+1}');\n")

    # purchase orders
    out.append("\n-- purchase_orders and items\n")
    for po in range(args.pos):
        supplier_id = random.randint(1, len(SUPPLIERS))
        po_num = f"PO-{po+1:05d}"
        order_date = (datetime.date.today() - datetime.timedelta(days=random.randint(1,90))).isoformat()
        expected = (datetime.date.today() + datetime.timedelta(days=random.randint(1,30))).isoformat()
        status = random.choice(['open','partial','received'])
        total = 0.0
        out.append(f"INSERT INTO purchase_orders (supplier_id, po_number, order_date, expected_date, status, total_amount) VALUES ({supplier_id},'{po_num}','{order_date}','{expected}','{status}',0.00);\n")
        # items
        items = random.randint(1,5)
        for it in range(items):
            product_id = random.randint(1, len(products))
            warehouse_id = random.randint(1, len(WAREHOUSES))
            qty = random.randint(1,200)
            unit_cost = round(random.uniform(0.5, 200.0),2)
            total += qty * unit_cost
            out.append(f"INSERT INTO purchase_order_items (po_id, product_id, warehouse_id, quantity_ordered, quantity_received, unit_cost) VALUES (LAST_INSERT_ID(),{product_id},{warehouse_id},{qty},{qty if status=='received' else 0},{unit_cost});\n")
        out.append(f"UPDATE purchase_orders SET total_amount = {round(total,2)} WHERE po_number = '{po_num}';\n")

    # sales orders
    out.append("\n-- sales_orders and items\n")
    for so in range(args.sos):
        customer_id = random.randint(1, args.customers)
        so_num = f"SO-{so+1:05d}"
        order_date = (datetime.date.today() - datetime.timedelta(days=random.randint(0,60))).isoformat()
        ship_date = (datetime.date.today() + datetime.timedelta(days=random.randint(0,7))).isoformat()
        status = random.choice(['pending','processing','shipped'])
        total = 0.0
        out.append(f"INSERT INTO sales_orders (customer_id, so_number, order_date, ship_date, status, total_amount) VALUES ({customer_id},'{so_num}','{order_date}','{ship_date}','{status}',0.00);\n")
        items = random.randint(1,5)
        for it in range(items):
            product_id = random.randint(1, len(products))
            warehouse_id = random.randint(1, len(WAREHOUSES))
            qty = random.randint(1,50)
            unit_price = float(products[product_id-1][4])
            total += qty * unit_price
            out.append(f"INSERT INTO sales_order_items (so_id, product_id, warehouse_id, quantity, unit_price) VALUES (LAST_INSERT_ID(),{product_id},{warehouse_id},{qty},{unit_price});\n")
            # inventory transaction
            out.append(f"INSERT INTO inventory_transactions (product_id, warehouse_id, txn_type, reference_id, quantity, unit_cost) VALUES ({product_id},{warehouse_id},'sale_out','{so_num}',{qty},{unit_price});\n")
        out.append(f"UPDATE sales_orders SET total_amount = {round(total,2)} WHERE so_number = '{so_num}';\n")

    return ''.join(out)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--products', type=int, default=200, help='Number of products to generate')
    p.add_argument('--customers', type=int, default=200, help='Number of customers to generate')
    p.add_argument('--pos', type=int, default=2000, help='Number of purchase orders to generate')
    p.add_argument('--sos', type=int, default=2000, help='Number of sales orders to generate')
    p.add_argument('--out', type=str, default='ims_sample_data_large.sql', help='Output SQL filename')
    args = p.parse_args()
    sql = generate(args)
    with open(args.out, 'w', encoding='utf-8') as f:
        f.write(sql)
    print(f'Wrote {args.out} (approx {len(sql)/1024:.1f} KB)')
