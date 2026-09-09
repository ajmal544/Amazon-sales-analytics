CREATE DATABASE amazon_sales;
USE amazon_sales;

CREATE TABLE sales (
    Order_ID VARCHAR(30),
    Date DATE,
    Status VARCHAR(50),
    Fulfilment VARCHAR(20),
    Sales_Channel VARCHAR(20),
    ship_service_level VARCHAR(20),
    Style VARCHAR(50),
    SKU VARCHAR(50),
    Category VARCHAR(50),
    Size VARCHAR(20),
    ASIN VARCHAR(20),
    Courier_Status VARCHAR(30),
    Qty INT,
    currency VARCHAR(10),
    Amount DECIMAL(10,2),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(10),
    promotion_ids TEXT,
    B2B BOOLEAN,
    fulfilled_by VARCHAR(30),
    is_cancelled BOOLEAN
);

TRUNCATE TABLE sales;
SELECT COUNT(*) FROM sales;

TRUNCATE TABLE sales;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/amazon_sales_cleaned.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Order_ID, Date, Status, Fulfilment, Sales_Channel, ship_service_level, Style, SKU, Category, Size, ASIN, Courier_Status, Qty, @currency, @amount, ship_city, ship_state, ship_postal_code, ship_country, promotion_ids, @b2b, fulfilled_by, @is_cancelled)
SET
  currency = NULLIF(@currency, ''),
  Amount = NULLIF(@amount, ''),
  B2B = CASE WHEN @b2b = 'True' THEN 1 ELSE 0 END,
  is_cancelled = CASE WHEN @is_cancelled = 'True' THEN 1 ELSE 0 END;

 SHOW VARIABLES LIKE 'secure_file_priv';
 
 SELECT COUNT(*) FROM sales;
 SELECT * FROM sales LIMIT 10;
 
 
 -- ============================================
-- Amazon Sales Analysis
-- ============================================

-- 1. Total revenue by category (excluding cancelled orders)
SELECT 
    Category,
    ROUND(SUM(Amount), 2) AS total_revenue,
    COUNT(*) AS order_count,
    ROUND(AVG(Amount), 2) AS avg_order_value
FROM sales
WHERE is_cancelled = 0
GROUP BY Category
ORDER BY total_revenue DESC;

-- 2. Monthly revenue trend
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS month,
    ROUND(SUM(Amount), 2) AS total_revenue,
    COUNT(*) AS order_count
FROM sales
WHERE is_cancelled = 0
GROUP BY month
ORDER BY month;



-- 3. Top 10 states by revenue
SELECT 
    ship_state,
    ROUND(SUM(Amount), 2) AS total_revenue,
    COUNT(*) AS order_count
FROM sales
WHERE is_cancelled = 0
GROUP BY ship_state
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Cancellation rate overall
SELECT 
    COUNT(*) AS total_orders,
    SUM(is_cancelled) AS cancelled_orders,
    ROUND(100 * SUM(is_cancelled) / COUNT(*), 2) AS cancellation_rate_pct
FROM sales;

-- 5. Cancellation rate by category
SELECT 
    Category,
    COUNT(*) AS total_orders,
    SUM(is_cancelled) AS cancelled_orders,
    ROUND(100 * SUM(is_cancelled) / COUNT(*), 2) AS cancellation_rate_pct
FROM sales
GROUP BY Category
ORDER BY cancellation_rate_pct DESC;

-- 6. Amazon vs Merchant fulfilment volume and revenue
SELECT 
    Fulfilment,
    COUNT(*) AS order_count,
    ROUND(SUM(Amount), 2) AS total_revenue
FROM sales
WHERE is_cancelled = 0
GROUP BY Fulfilment;

-- 7. B2B vs B2C comparison
SELECT 
    B2B,
    COUNT(*) AS order_count,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(100 * SUM(is_cancelled) / COUNT(*), 2) AS cancellation_rate_pct
FROM sales
GROUP BY B2B;

-- 8. Most common ship-service-level
SELECT 
    ship_service_level,
    COUNT(*) AS order_count
FROM sales
GROUP BY ship_service_level
ORDER BY order_count DESC;

SELECT is_cancelled, COUNT(*) FROM sales GROUP BY is_cancelled;

SELECT MIN(Date) AS earliest, MAX(Date) AS latest FROM sales;
