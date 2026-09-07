# Amazon Sales Analytics

An end-to-end data analytics project covering data cleaning, database loading, SQL analysis, and dashboard visualization — built on a real-world Amazon sales dataset (March–June 2022).

## Project Structure

```
Amazon-Sales-Analytics/
│
├── data/
│   ├── sales_dataset.xlsx          ← Raw data
│   └── amazon_sales_cleaned.csv    ← Cleaned output
│
├── python/
│   └── data_cleaning.py            ← Cleaning pipeline
│
├── sql/
│   └── analysis.sql                ← Analysis queries
│
├── powerbi/
│   └── Amazon_Sales.pbix           ← Dashboard
│
└── README.md
```

## Pipeline Overview

1. **Extract** — Raw sales data loaded from Excel (`.xlsx`) using pandas
2. **Clean** — Python script handles missing values, duplicates, type conversion, and column standardization
3. **Load** — Cleaned CSV imported into MySQL for structured querying
4. **Analyze** — SQL queries answer specific business questions (revenue, cancellations, geography, fulfilment)
5. **Visualize** — Power BI dashboard connects live to MySQL via ODBC for interactive exploration

## Data Cleaning Decisions

The raw dataset (128,949 rows × 23 columns) required cleaning before analysis. Every decision below was based on verifying *why* data was missing, not applying blanket rules:

| Issue | Decision | Reasoning |
|---|---|---|
| Junk `Unnamed: 22` column | Dropped | No real header, Excel export artifact |
| 6 exact duplicate rows | Dropped | Byte-for-byte identical, no new information |
| 33 rows missing shipping info | Dropped | Negligible fraction (0.03%), likely entry errors |
| `Amount`/`currency` nulls (7,794) | Kept as NULL, flagged with `is_cancelled` | ~97% structurally tied to Cancelled orders — a cancelled order has no valid transaction amount |
| `Courier_Status` nulls (6,871) | Kept as NULL | Same pattern — mostly Cancelled orders that never reached a courier |
| `fulfilled_by` nulls (89,679) | Kept as NULL | Structural — this field only applies to Merchant-fulfilled orders (confirmed: 100% of nulls are `Fulfilment = Amazon`) |
| `promotion_ids` nulls (49,142) | Filled with `'None'` | Null means "no promotion applied" — a real, meaningful state worth making explicit |
| Column names (`ship-city`, etc.) | Standardized to snake_case | Hyphens break Python attribute access and require escaping in SQL |

**Known data quality gap:** 231 non-cancelled orders (mostly `Shipped`) still have missing `Amount` values. This doesn't fit the "cancelled = no amount" pattern and is flagged as a genuine gap for further investigation, rather than assumed away.

## Key Business Findings

**Revenue & Volume**
- Total revenue: ~₹77.9M across ~129K orders (Mar–Jun 2022)
- Kurta and Set categories drive ~78% of total order volume
- Overall cancellation rate: 14.26% (B2C) vs. 8.38% (B2B) — B2B orders are notably more reliable, though B2B is under 1% of total volume

**Geographic Concentration**
- Maharashtra and Karnataka are the top two states by revenue, together outpacing several other top-10 states combined
- Revenue is concentrated in major urban/tech-hub states (Maharashtra, Karnataka, Telangana, Tamil Nadu)

**Fulfilment & Shipping**
- Amazon-fulfilled orders (78,181) outnumber Merchant-fulfilled (32,398) roughly 2.4:1
- Average order value is nearly identical across both fulfilment types (~₹646 vs ~₹650) — fulfilment channel is an operations choice, not a driver of customer spend
- Expedited shipping is used more than twice as often as Standard shipping

**Cancellations**
- 14.6% of all orders are cancelled — a meaningful share of lost potential revenue
- The highest-volume categories (Set, Kurta) also carry the highest cancellation rates (~14.5–14.6%), meaning cancellation risk is concentrated exactly where the business has the most exposure

## Tools Used

- **Python** (pandas, openpyxl) — data cleaning
- **MySQL** (MySQL Workbench) — data storage and querying
- **Power BI Desktop** — dashboard and visualization, connected via ODBC
- **VS Code** — development environment

## How to Reproduce

1. Run `python/data_cleaning.py` to generate `data/amazon_sales_cleaned.csv` from the raw Excel file
2. Load the cleaned CSV into a MySQL database named `amazon_sales` (see `sql/analysis.sql` for table schema and load statement)
3. Run the queries in `sql/analysis.sql` to reproduce the analysis
4. Open `powerbi/Amazon_Sales.pbix` and connect to your local MySQL instance to refresh the dashboard
