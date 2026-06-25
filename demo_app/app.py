from flask import Flask, request, jsonify
import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('DB_HOST','127.0.0.1'),
    'user': os.getenv('DB_USER','root'),
    'password': os.getenv('DB_PASS',''),
    'database': os.getenv('DB_NAME','ims')
}

app = Flask(__name__)

def get_conn():
    return mysql.connector.connect(**DB_CONFIG)

@app.route('/products', methods=['GET'])
def list_products():
    cnx = get_conn()
    cur = cnx.cursor(dictionary=True)
    cur.execute('SELECT product_id, sku, name, unit_price, reorder_level FROM products LIMIT 1000')
    rows = cur.fetchall()
    cur.close(); cnx.close()
    return jsonify(rows)

@app.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    cnx = get_conn(); cur = cnx.cursor(dictionary=True)
    cur.execute('SELECT * FROM products WHERE product_id = %s', (product_id,))
    row = cur.fetchone()
    cur.close(); cnx.close()
    if not row:
        return jsonify({'error':'Not found'}), 404
    return jsonify(row)

@app.route('/products', methods=['POST'])
def create_product():
    data = request.json
    cnx = get_conn(); cur = cnx.cursor()
    cur.execute('INSERT INTO products (sku, name, category_id, supplier_id, unit_price, reorder_level) VALUES (%s,%s,%s,%s,%s,%s)',
                (data.get('sku'), data.get('name'), data.get('category_id'), data.get('supplier_id'), data.get('unit_price',0), data.get('reorder_level',0)))
    cnx.commit()
    pid = cur.lastrowid
    cur.close(); cnx.close()
    return jsonify({'product_id': pid}), 201

@app.route('/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    data = request.json
    fields = []
    params = []
    for k in ['sku','name','category_id','supplier_id','unit_price','reorder_level']:
        if k in data:
            fields.append(f"{k} = %s")
            params.append(data[k])
    if not fields:
        return jsonify({'error':'No fields to update'}), 400
    params.append(product_id)
    cnx = get_conn(); cur = cnx.cursor()
    cur.execute(f"UPDATE products SET {', '.join(fields)} WHERE product_id = %s", tuple(params))
    cnx.commit(); cur.close(); cnx.close()
    return jsonify({'updated': True})

@app.route('/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    cnx = get_conn(); cur = cnx.cursor()
    cur.execute('DELETE FROM products WHERE product_id = %s', (product_id,))
    cnx.commit(); cur.close(); cnx.close()
    return jsonify({'deleted': True})

@app.route('/stock/<int:product_id>', methods=['GET'])
def get_stock(product_id):
    cnx = get_conn(); cur = cnx.cursor(dictionary=True)
    cur.execute('SELECT warehouse_id, quantity FROM stock_levels WHERE product_id = %s', (product_id,))
    rows = cur.fetchall(); cur.close(); cnx.close()
    return jsonify(rows)

@app.route('/stock/update', methods=['POST'])
def update_stock():
    data = request.json
    pid = data['product_id']; wid = data['warehouse_id']; qty = data['quantity']
    cnx = get_conn(); cur = cnx.cursor()
    # upsert
    cur.execute('SELECT stock_id FROM stock_levels WHERE product_id=%s AND warehouse_id=%s', (pid,wid))
    r = cur.fetchone()
    if r:
        cur.execute('UPDATE stock_levels SET quantity=%s WHERE stock_id=%s', (qty, r[0]))
    else:
        cur.execute('INSERT INTO stock_levels (product_id, warehouse_id, quantity) VALUES (%s,%s,%s)', (pid,wid,qty))
    # insert txn
    cur.execute("INSERT INTO inventory_transactions (product_id, warehouse_id, txn_type, reference_id, quantity) VALUES (%s,%s,'adjustment',NULL,%s)", (pid,wid,qty))
    cnx.commit(); cur.close(); cnx.close()
    return jsonify({'updated': True})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
