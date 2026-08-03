/* ============================================================
   E-COMMERCE SALES PERFORMANCE ANALYSIS
   SQL Analysis Script  (SQLite)
   Dataset: Superstore Sales (~9,994 order-line rows)
   Table : orders
   ------------------------------------------------------------
   Columns:
   row_id, order_id, order_date, ship_date, ship_mode,
   customer_id, customer_name, segment, country, city, state,
   postal_code, region, product_id, category, sub_category,
   product_name, sales, quantity, discount, profit
   ============================================================ */

/* ────────────────────────────────────────────────────────────────
   SECTION 1 : HIGH-LEVEL KPIs
   ──────────────────────────────────────────────────────────────── */

-- 1. Total sales
SELECT ROUND(SUM(sales), 2) AS total_sales
FROM orders;
-- RESULT: total_sales = 2,297,200.86

-- 2. Total profit
SELECT ROUND(SUM(profit), 2) AS total_profit
FROM orders;
-- RESULT: total_profit = 286,397.02

-- 3. Total number of orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;
-- RESULT: total_orders = 5,009

-- 4. Overall profit margin (%)
SELECT ROUND(SUM(profit) * 1.0 / NULLIF(SUM(sales), 0) * 100, 2)
       AS profit_margin_pct
FROM orders;
-- RESULT: profit_margin_pct = 12.47 %

-- 5. Average order value (AOV)
SELECT ROUND(SUM(sales) * 1.0 / COUNT(DISTINCT order_id), 2)
       AS avg_order_value
FROM orders;
-- RESULT: avg_order_value = 458.61

/* ────────────────────────────────────────────────────────────────
   SECTION 2 : TIME TRENDS
   ──────────────────────────────────────────────────────────────── */

-- 6. Monthly sales trend
SELECT strftime('%Y-%m', order_date)    AS order_month,
       ROUND(SUM(sales), 2)            AS monthly_sales,
       ROUND(SUM(profit), 2)           AS monthly_profit
FROM   orders
GROUP  BY order_month
ORDER  BY order_month;
-- RESULT: 48 rows (Jan 2014 – Dec 2017)

-- 7. Year-over-year sales growth
WITH yearly AS (
    SELECT strftime('%Y', order_date) AS order_year,
           ROUND(SUM(sales), 2)      AS yearly_sales
    FROM   orders
    GROUP  BY order_year
)
SELECT order_year,
       yearly_sales,
       ROUND(
           (yearly_sales - LAG(yearly_sales) OVER (ORDER BY order_year))
           * 1.0
           / NULLIF(LAG(yearly_sales) OVER (ORDER BY order_year), 0)
           * 100, 2
       ) AS yoy_growth_pct
FROM   yearly
ORDER  BY order_year;
-- RESULT:
--   2014: $484,247.50  (baseline)
--   2015: $470,532.51  (-2.83%)
--   2016: $609,205.60  (+29.47%)
--   2017: $733,215.26  (+20.36%)

-- 8. Sales by quarter
SELECT strftime('%Y', order_date) AS order_year,
       ((CAST(strftime('%m', order_date) AS INTEGER) - 1) / 3 + 1)
                                  AS order_quarter,
       ROUND(SUM(sales), 2)      AS quarterly_sales
FROM   orders
GROUP  BY order_year, order_quarter
ORDER  BY order_year, order_quarter;
-- RESULT: 16 rows (Q1-2014 through Q4-2017)

-- 9. Busiest sales month across all years (seasonality check)
SELECT CAST(strftime('%m', order_date) AS INTEGER) AS month_number,
       ROUND(SUM(sales), 2)                       AS total_sales
FROM   orders
GROUP  BY month_number
ORDER  BY total_sales DESC;
-- RESULT (top 3):
--   November  : $352,461.07
--   December  : $325,293.50
--   September : $307,649.95

-- 10. Average shipping delay (days) by month
SELECT strftime('%Y-%m', order_date) AS order_month,
       ROUND(AVG(julianday(ship_date) - julianday(order_date)), 1)
                                     AS avg_ship_days
FROM   orders
GROUP  BY order_month
ORDER  BY order_month;
-- RESULT: 48 rows; overall average ≈ 4 days

/* ────────────────────────────────────────────────────────────────
   SECTION 3 : PRODUCT PERFORMANCE
   ──────────────────────────────────────────────────────────────── */

-- 11. Top 10 products by sales
SELECT product_name,
       ROUND(SUM(sales), 2) AS total_sales
FROM   orders
GROUP  BY product_name
ORDER  BY total_sales DESC
LIMIT  10;
-- RESULT:
--   1. Canon imageCLASS 2200 Advanced Copier           $61,599.82
--   2. Fellowes PB500 Electric Punch Plastic Comb …    $27,453.38
--   3. Cisco TelePresence System EX90                  $22,638.48
--   4. HON 5400 Series Task Chairs for Big and Tall    $21,870.58
--   5. GBC DocuBind TL300 Electric Binding System      $19,823.48

-- 12. Bottom 10 products by sales
SELECT product_name,
       ROUND(SUM(sales), 2) AS total_sales
FROM   orders
GROUP  BY product_name
ORDER  BY total_sales ASC
LIMIT  10;
-- RESULT: lowest-selling products with sales < $2 each

-- 13. Top 10 products by profit
SELECT product_name,
       ROUND(SUM(profit), 2) AS total_profit
FROM   orders
GROUP  BY product_name
ORDER  BY total_profit DESC
LIMIT  10;
-- RESULT:
--   1. Canon imageCLASS 2200 Advanced Copier           $25,199.93
--   (top profit generator, matching top sales product)

-- 14. Products that are loss-making (negative profit)
SELECT product_name,
       ROUND(SUM(profit), 2) AS total_profit
FROM   orders
GROUP  BY product_name
HAVING SUM(profit) < 0
ORDER  BY total_profit ASC;
-- RESULT: 302 products with negative total profit

-- 15. Sales and profit by category
SELECT category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) * 1.0 / NULLIF(SUM(sales), 0) * 100, 2)
                              AS profit_margin_pct
FROM   orders
GROUP  BY category
ORDER  BY total_sales DESC;
-- RESULT:
--   Technology     : Sales $836,154.03  | Profit $145,454.95 | Margin 17.40%
--   Furniture      : Sales $741,999.80  | Profit  $18,451.27 | Margin  2.49%
--   Office Supplies: Sales $719,047.03  | Profit $122,490.80 | Margin 17.04%

-- 16. Sales and profit by sub-category
SELECT sub_category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM   orders
GROUP  BY sub_category
ORDER  BY total_profit DESC;
-- RESULT: 17 sub-categories; top = Copiers, bottom = Tables (loss-making)

-- 17. Average profit margin by category (ranked)
SELECT category,
       ROUND(AVG(profit * 1.0 / NULLIF(sales, 0)) * 100, 2)
              AS avg_margin_pct
FROM   orders
GROUP  BY category
ORDER  BY avg_margin_pct DESC;
-- RESULT:
--   Technology      : 20.60%   (avg per-order margin)
--   Office Supplies : 17.60%
--   Furniture       : -5.77%   (many loss-making furniture orders)

/* ────────────────────────────────────────────────────────────────
   SECTION 4 : GEOGRAPHIC PERFORMANCE
   ──────────────────────────────────────────────────────────────── */

-- 18. Sales and profit by region
SELECT region,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) * 1.0 / NULLIF(SUM(sales), 0) * 100, 2)
                              AS profit_margin_pct
FROM   orders
GROUP  BY region
ORDER  BY total_profit DESC;
-- RESULT:
--   West    : Sales $725,457.82 | Profit $108,418.45 | Margin 14.94%
--   East    : Sales $678,781.24 | Profit  $91,522.78 | Margin 13.48%
--   South   : Sales $391,721.91 | Profit  $46,749.43 | Margin 11.93%
--   Central : Sales $501,239.89 | Profit  $39,706.36 | Margin  7.92%

-- 19. Top 10 cities by sales
SELECT city, state,
       ROUND(SUM(sales), 2) AS total_sales
FROM   orders
GROUP  BY city, state
ORDER  BY total_sales DESC
LIMIT  10;
-- RESULT:
--   1. New York City, New York          $256,368.16
--   2. Los Angeles, California          $175,851.38
--   3. Seattle, Washington              $116,106.32
--   (+ 7 more cities)

-- 20. Top 10 states by profit
SELECT state,
       ROUND(SUM(profit), 2) AS total_profit
FROM   orders
GROUP  BY state
ORDER  BY total_profit DESC
LIMIT  10;
-- RESULT:
--   1. California     : $76,381.39
--   2. New York       : $74,038.55
--   3. Washington     : $33,402.65
--   (+ 7 more states)

-- 21. States with negative profit (underperforming markets)
SELECT state,
       ROUND(SUM(profit), 2) AS total_profit
FROM   orders
GROUP  BY state
HAVING SUM(profit) < 0
ORDER  BY total_profit ASC;
-- RESULT: 10 states with negative profit
--   Texas           : -$25,729.36
--   Ohio            : -$16,971.38
--   Pennsylvania    : -$15,559.96
--   Illinois        : -$12,607.89
--   North Carolina  : -$7,490.91
--   Colorado        : -$6,527.86
--   Tennessee       : -$5,341.69
--   Arizona         : -$3,427.92
--   Florida         : -$3,399.30
--   Oregon          : -$1,190.47

/* ────────────────────────────────────────────────────────────────
   SECTION 5 : CUSTOMER ANALYSIS
   ──────────────────────────────────────────────────────────────── */

-- 22. Top 10 customers by total purchase value
SELECT customer_name,
       ROUND(SUM(sales), 2) AS total_purchases
FROM   orders
GROUP  BY customer_name
ORDER  BY total_purchases DESC
LIMIT  10;
-- RESULT:
--   1. Sean Miller           : $25,043.05
--   2. Tamara Chand          : $19,052.22
--   (+ 8 more customers)

-- 23. Sales, profit, and order count by customer segment
SELECT segment,
       COUNT(DISTINCT order_id)   AS num_orders,
       ROUND(SUM(sales), 2)      AS total_sales,
       ROUND(SUM(profit), 2)     AS total_profit,
       ROUND(SUM(sales) * 1.0 / COUNT(DISTINCT order_id), 2)
                                  AS avg_order_value
FROM   orders
GROUP  BY segment
ORDER  BY total_sales DESC;
-- RESULT:
--   Consumer    : 2,586 orders | Sales $1,161,401.34 | Profit $134,119.21 | AOV $449.11
--   Corporate   : 1,514 orders | Sales $706,146.37   | Profit  $91,979.13 | AOV $466.41
--   Home Office :   909 orders | Sales $429,653.15   | Profit  $60,298.68 | AOV $472.67

-- 24. Repeat vs. one-time customers
SELECT CASE WHEN order_count = 1 THEN 'One-time'
            ELSE 'Repeat'
       END AS customer_type,
       COUNT(*) AS num_customers
FROM   (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS order_count
    FROM   orders
    GROUP  BY customer_id
) t
GROUP BY customer_type;
-- RESULT:
--   One-time :  12 customers
--   Repeat   : 781 customers (98.5%)

/* ────────────────────────────────────────────────────────────────
   SECTION 6 : DISCOUNT & PRICING ANALYSIS
   ──────────────────────────────────────────────────────────────── */

-- 25. Discount level vs. average profit margin
SELECT CASE
           WHEN discount = 0    THEN '0% (No discount)'
           WHEN discount <= 0.10 THEN '1-10%'
           WHEN discount <= 0.20 THEN '11-20%'
           WHEN discount <= 0.30 THEN '21-30%'
           ELSE '30%+'
       END AS discount_band,
       COUNT(*)                   AS num_orders,
       ROUND(AVG(profit * 1.0 / NULLIF(sales, 0)) * 100, 2)
                                  AS avg_margin_pct,
       ROUND(SUM(profit), 2)     AS total_profit
FROM   orders
GROUP  BY discount_band
ORDER  BY discount_band;
-- RESULT:
--   0% (No discount) : 4,798 orders | Margin 34.02% | Profit $320,987.60
--   1-10%            :    94 orders | Margin 15.58% | Profit   $9,029.18
--   11-20%           : 3,709 orders | Margin 17.48% | Profit  $91,756.30
--   21-30%           :   227 orders | Margin -11.55%| Profit -$10,369.28
--   30%+             : 1,166 orders | Margin -91.47%| Profit -$125,006.78

-- BONUS 26. Correlation check: does higher discount consistently erode profit?
SELECT category,
       ROUND(AVG(discount) * 100, 2) AS avg_discount_pct,
       ROUND(AVG(profit * 1.0 / NULLIF(sales, 0)) * 100, 2)
                                      AS avg_margin_pct
FROM   orders
GROUP  BY category
ORDER  BY avg_discount_pct DESC;
-- RESULT:
--   Furniture       : Avg Discount 17.06% → Avg Margin -5.77%
--   Office Supplies : Avg Discount 15.62% → Avg Margin 17.60%
--   Technology      : Avg Discount 13.95% → Avg Margin 20.60%

-- BONUS 27. Orders sold at a loss due to discounting
SELECT COUNT(*) AS loss_making_orders
FROM   orders
WHERE  profit < 0
  AND  discount > 0;
-- RESULT: 1,871 loss-making discounted orders
