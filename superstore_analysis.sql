-- ==========================================
-- SUPERSTORE SALES DATA ANALYSIS
-- ==========================================

-- 1. Create and populate Customers table
CREATE TABLE customers AS
SELECT DISTINCT 
    `Customer ID` AS customer_id, 
    `Customer Name` AS customer_name, 
    `Segment` AS segment
FROM superstore_raw;

-- 2. Create and populate Products table
CREATE TABLE products AS
SELECT DISTINCT 
    `Product ID` AS product_id, 
    `Product Name` AS product_name, 
    `Category` AS category, 
    `Sub-Category` AS sub_category
FROM superstore_raw;

-- 3. Create and populate Orders table
CREATE TABLE orders AS
SELECT DISTINCT 
    `Row ID` AS row_id,
    `Order ID` AS order_id, 
    `Order Date` AS order_date, 
    `Customer ID` AS customer_id, 
    `Product ID` AS product_id, 
    `Sales` AS sales, 
    `Quantity` AS quantity
FROM superstore_raw;

-- ==========================================
-- ADVANCED SQL ANALYSIS TASKS
-- ==========================================

-- Task 1: Orders with sales greater than the average sales
SELECT order_id, sales 
FROM orders 
WHERE sales > (SELECT AVG(sales) FROM orders);

-- Task 2: Highest sales order per customer
SELECT o1.customer_id, o1.order_id, o1.sales
FROM orders o1
WHERE o1.sales = (
    SELECT MAX(o2.sales) 
    FROM orders o2 
    WHERE o2.customer_id = o1.customer_id
);

-- Task 3: Total sales per customer using CTE
WITH CustomerSalesCTE AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT * FROM CustomerSalesCTE;

-- Task 4: Customers with total sales above average total sales
WITH CustomerSalesCTE AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id, total_sales 
FROM CustomerSalesCTE
WHERE total_sales > (SELECT AVG(total_sales) FROM CustomerSalesCTE);

-- Task 5: Rank customers based on total sales using RANK()
WITH CustomerSales AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id, 
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM CustomerSales;

-- Task 6: Assign row numbers partitioned by customer sorted by date
SELECT 
    customer_id, 
    order_id, 
    sales,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS order_row_num
FROM orders;

-- Task 7: Top 3 customers based on total sales using DENSE_RANK()
WITH RankedCustomers AS (
    SELECT 
        customer_id, 
        SUM(sales) AS total_sales,
        DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS rnk
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id, total_sales, rnk
FROM RankedCustomers
WHERE rnk <= 3;

-- ==========================================
-- MINIPROJECT INSIGHTS
-- ==========================================

-- Top 5 customers by sales
SELECT c.customer_name, SUM(o.sales) AS total_sales
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name ORDER BY total_sales DESC LIMIT 5;

-- Bottom 5 customers by sales
SELECT c.customer_name, SUM(o.sales) AS total_sales
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name ORDER BY total_sales ASC LIMIT 5;

-- Single order customers
SELECT c.customer_name, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name HAVING COUNT(DISTINCT o.order_id) = 1;
