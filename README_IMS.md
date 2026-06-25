# Updated README_IMS.md

I added:
- tools/generate_large_data.py (generator script to create large SQL dataset)
- demo_app/ (Flask demo with CRUD endpoints)
- sample_reports/ims_reports.sql (useful queries and reports)

To generate a large dataset (example 2000 POs and 2000 SOs):
python tools/generate_large_data.py --products 500 --customers 500 --pos 2000 --sos 2000 --out ims_sample_data_large.sql

Then load the generated file into MySQL (after running ims_schema.sql):
mysql -u root -p < ims_sample_data_large.sql

Demo app setup:
cd demo_app
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
# configure DB credentials in environment (DB_HOST, DB_USER, DB_PASS, DB_NAME)
python app.py

