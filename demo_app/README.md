# Demo Flask app for IMS

This simple Flask app demonstrates basic CRUD operations for products and stock levels.

Requirements
- Python 3.8+
- pip install -r requirements.txt

Run
- Update the DB config in app.py
- python app.py

Endpoints
- GET /products
- GET /products/<id>
- POST /products
- PUT /products/<id>
- DELETE /products/<id>

- GET /stock/<product_id>
- POST /stock/update  (body: product_id, warehouse_id, quantity)
