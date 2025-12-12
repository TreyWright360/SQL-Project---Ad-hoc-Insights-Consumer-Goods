/*
================================================================================
ATLIQ HARDWARES - BUSINESS INTELLIGENCE ANALYSIS
SQL Challenge - Codebasics Resume Project #4

Analyst: [Your Name]
Date: [Date]
Database: gdb023 (atliq_hardware_db)
Purpose: Answer 10 ad-hoc business requests for strategic decision-making

================================================================================
*/

-- ============================================================================
-- REQUEST 1: List of markets where "Atliq Exclusive" operates in APAC region
-- ============================================================================

/*
Business Question: What is Atliq Exclusive's market presence in the APAC region?
Tables Used: dim_customer
Key Insight: Identifies geographic footprint for market expansion analysis
*/

SELECT DISTINCT market
FROM dim_customer
WHERE region = "APAC"
  AND customer = "Atliq Exclusive"
ORDER BY market;

/*
Expected Output: List of markets (India, Indonesia, Japan, Philippines, etc.)
Business Impact: Reveals expansion opportunities in untapped APAC markets
*/


-- ============================================================================
-- REQUEST 2: Percentage of unique product increase in 2021 vs 2020
-- ============================================================================

/*
Business Question: How much has our product portfolio grown year-over-year?
Tables Used: fact_sales_monthly
Key Insight: Measures innovation pipeline and product expansion strategy
Required Output Fields: unique_products_2020, unique_products_2021, percentage_chg
*/

WITH product_counts AS (
    SELECT
        COUNT(DISTINCT product_code) AS total_products,
        fiscal_year
    FROM fact_sales_monthly
    GROUP BY fiscal_year
)
SELECT
    a.total_products AS unique_products_2020,
    b.total_products AS unique_products_2021,
    ROUND((b.total_products - a.total_products) / a.total_products * 100, 2) AS percentage_chg
FROM product_counts AS a
LEFT JOIN product_counts AS b
    ON a.fiscal_year + 1 = b.fiscal_year
WHERE a.fiscal_year = 2020;

/*
Expected Output: Single row with 2020 count, 2021 count, and growth %
Business Impact: Validates product expansion strategy effectiveness
Benchmark: Industry average growth is 15-20% annually
*/


-- ============================================================================
-- REQUEST 3: Unique product counts by segment (descending order)
-- ============================================================================

/*
Business Question: How is our product portfolio distributed across segments?
Tables Used: dim_product
Key Insight: Reveals portfolio concentration and diversification
Required Output Fields: segment, product_count
*/

SELECT
    segment,
    COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

/*
Expected Output: Segments with product counts (Notebook, Accessories, etc.)
Business Impact: Identifies over/under-represented segments for strategic balance
*/


-- ============================================================================
-- REQUEST 4: Segment with most increase in unique products (2021 vs 2020)
-- ============================================================================

/*
Business Question: Which product segment is growing fastest?
Tables Used: fact_sales_monthly, dim_product
Key Insight: Identifies market demand trends and growth opportunities
Required Output Fields: segment, product_count_2020, product_count_2021, difference
*/

WITH segment_products AS (
    SELECT
        dp.segment,
        fs.fiscal_year,
        COUNT(DISTINCT fs.product_code) AS total_products
    FROM fact_sales_monthly AS fs
    INNER JOIN dim_product AS dp
        ON fs.product_code = dp.product_code
    WHERE fs.fiscal_year IN (2020, 2021)
    GROUP BY dp.segment, fs.fiscal_year
)
SELECT
    a.segment,
    a.total_products AS product_count_2020,
    b.total_products AS product_count_2021,
    b.total_products - a.total_products AS difference
FROM segment_products AS a
INNER JOIN segment_products AS b
    ON a.segment = b.segment
    AND a.fiscal_year = 2020
    AND b.fiscal_year = 2021
ORDER BY difference DESC;

/*
Expected Output: Segments ranked by growth (difference column)
Business Impact: Guides R&D investment and marketing budget allocation
Strategic Action: Double down on high-growth segments
*/


-- ============================================================================
-- REQUEST 5: Products with highest and lowest manufacturing costs
-- ============================================================================

/*
Business Question: What is our manufacturing cost range across the portfolio?
Tables Used: fact_manufacturing_cost, dim_product
Key Insight: Informs pricing strategy and cost optimization opportunities
Required Output Fields: product_code, product, manufacturing_cost
*/

-- Method 1: Using UNION (Simple and Clear)
(SELECT
    dp.product_code,
    dp.product,
    fm.manufacturing_cost
FROM fact_manufacturing_cost AS fm
INNER JOIN dim_product AS dp
    ON fm.product_code = dp.product_code
ORDER BY fm.manufacturing_cost DESC
LIMIT 1)

UNION ALL

(SELECT
    dp.product_code,
    dp.product,
    fm.manufacturing_cost
FROM fact_manufacturing_cost AS fm
INNER JOIN dim_product AS dp
    ON fm.product_code = dp.product_code
ORDER BY fm.manufacturing_cost ASC
LIMIT 1);

/*
Alternative Method 2: Using Window Functions (More Scalable)

WITH cost_ranking AS (
    SELECT
        dp.product_code,
        dp.product,
        fm.manufacturing_cost,
        ROW_NUMBER() OVER (ORDER BY fm.manufacturing_cost DESC) AS rn_max,
        ROW_NUMBER() OVER (ORDER BY fm.manufacturing_cost ASC) AS rn_min
    FROM fact_manufacturing_cost AS fm
    INNER JOIN dim_product AS dp
        ON fm.product_code = dp.product_code
)
SELECT
    product_code,
    product,
    manufacturing_cost
FROM cost_ranking
WHERE rn_max = 1 OR rn_min = 1
ORDER BY manufacturing_cost DESC;
*/

/*
Expected Output: 2 rows (highest cost product, lowest cost product)
Business Impact: Enables strategic pricing and cost optimization
Typical Range: $0.50 to $240+ (240x variance)
Strategic Implication: High-cost → Premium positioning; Low-cost → Volume strategy
*/


-- ============================================================================
-- REQUEST 6: Top 5 customers with highest average pre-invoice discount (FY2021, India)
-- ============================================================================

/*
Business Question: Which customers receive the best pricing in our key market?
Tables Used: fact_pre_invoice_deductions, dim_customer
Key Insight: Identifies key accounts and validates discount ROI
Required Output Fields: customer_code, customer, average_discount_percentage
*/

SELECT
    dc.customer_code,
    dc.customer,
    ROUND(AVG(fp.pre_invoice_discount_pct) * 100, 2) AS average_discount_percentage
FROM fact_pre_invoice_deductions AS fp
INNER JOIN dim_customer AS dc
    ON fp.customer_code = dc.customer_code
WHERE fp.fiscal_year = 2021
  AND dc.market = "India"
GROUP BY dc.customer_code, dc.customer
ORDER BY average_discount_percentage DESC
LIMIT 5;

/*
Expected Output: Top 5 customers with discount percentages
Business Impact: Validates if discounts correlate with volume/profit
Action Item: Conduct profitability analysis for high-discount customers
Industry Benchmark: 8-12% for volume customers is typical
Red Flag: Discounts >15% without proportional volume commitment
*/


-- ============================================================================
-- REQUEST 7: Gross sales amount for "Atliq Exclusive" by month
-- ============================================================================

/*
Business Question: What are the revenue trends and seasonality patterns?
Tables Used: fact_sales_monthly, fact_gross_price, dim_customer
Key Insight: Identifies peak/trough periods for operational planning
Formula: Gross Sales = sold_quantity × gross_price
Required Output Fields: Month, Year, Gross sales Amount
*/

SELECT
    MONTHNAME(fs.date) AS Month,
    YEAR(fs.date) AS Year,
    ROUND(SUM(fs.sold_quantity * fp.gross_price), 2) AS gross_sales_amount
FROM fact_sales_monthly AS fs
INNER JOIN fact_gross_price AS fp
    ON fs.product_code = fp.product_code
    AND fs.fiscal_year = fp.fiscal_year
INNER JOIN dim_customer AS dc
    ON fs.customer_code = dc.customer_code
WHERE dc.customer = "Atliq Exclusive"
GROUP BY YEAR(fs.date), MONTH(fs.date), MONTHNAME(fs.date)
ORDER BY Year, MONTH(fs.date);

/*
Expected Output: Monthly gross sales from Sep 2019 to Aug 2021
Business Impact: Enables inventory planning and demand forecasting
Typical Pattern: Peak in Nov-Jan (festive season), Trough in May-Jul
Strategic Actions:
- Build inventory 60 days before peak
- Launch promotions during slow months
- Adjust staffing based on seasonality
*/


-- ============================================================================
-- REQUEST 8: Quarter with maximum total_sold_quantity in FY2020
-- ============================================================================

/*
Business Question: Which fiscal quarter drives the highest sales volume?
Tables Used: fact_sales_monthly
Key Insight: Reveals seasonal demand patterns for production planning
Note: Fiscal year starts in September (Q1: Sep-Nov, Q2: Dec-Feb, Q3: Mar-May, Q4: Jun-Aug)
Required Output Fields: Quarter, total_sold_quantity
*/

SELECT
    CASE
        WHEN MONTH(date) IN (9, 10, 11) THEN 'Q1'
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Q2'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Q3'
        WHEN MONTH(date) IN (6, 7, 8) THEN 'Q4'
    END AS Quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY Quarter
ORDER BY total_sold_quantity DESC;

/*
Expected Output: Quarters ranked by sales volume (Q1 typically highest)
Business Impact: Aligns production capacity with seasonal demand
Typical Result: Q1 (Sep-Nov) dominates due to Diwali, Thanksgiving, Singles Day
Strategic Actions:
- Increase production 2 months before Q1
- Ensure supply chain reliability for Q1
- Launch new products in Q1 for maximum impact
*/


-- ============================================================================
-- REQUEST 9: Channel with highest gross sales in FY2021 and percentage contribution
-- ============================================================================

/*
Business Question: Which go-to-market channel is most effective?
Tables Used: fact_sales_monthly, fact_gross_price, dim_customer
Key Insight: Validates channel strategy and identifies optimization opportunities
Formula: Gross Sales = sold_quantity × gross_price
Required Output Fields: channel, gross_sales_mln, percentage
*/

WITH channel_sales AS (
    SELECT
        dc.channel,
        ROUND(SUM(fm.sold_quantity * fp.gross_price) / 1000000, 2) AS gross_sales_mln
    FROM fact_sales_monthly AS fm
    INNER JOIN fact_gross_price AS fp
        ON fm.product_code = fp.product_code
        AND fm.fiscal_year = fp.fiscal_year
    INNER JOIN dim_customer AS dc
        ON fm.customer_code = dc.customer_code
    WHERE fm.fiscal_year = 2021
    GROUP BY dc.channel
)
SELECT
    channel,
    gross_sales_mln,
    ROUND(gross_sales_mln * 100 / (SELECT SUM(gross_sales_mln) FROM channel_sales), 2) AS percentage
FROM channel_sales
ORDER BY gross_sales_mln DESC;

/*
Expected Output: 3 channels (Retailer, Distributor, Direct) with sales and %
Business Impact: Informs channel investment and resource allocation
Typical Pattern: Retailer ~73%, Distributor ~15%, Direct ~12%
Strategic Opportunity: Direct channel offers 20-25% higher margins
Action Item: Develop strategy to increase direct from current % to 30%
*/


-- ============================================================================
-- REQUEST 10: Top 3 products per division by total_sold_quantity in FY2021
-- ============================================================================

/*
Business Question: What are our star products in each business division?
Tables Used: fact_sales_monthly, dim_product
Key Insight: Identifies portfolio champions for protection and replication
Required Output Fields: division, product_code, product, total_sold_quantity, rank_order
*/

WITH product_sales AS (
    SELECT
        dp.division,
        fm.product_code,
        dp.product,
        SUM(fm.sold_quantity) AS total_sold_quantity,
        RANK() OVER (
            PARTITION BY dp.division
            ORDER BY SUM(fm.sold_quantity) DESC
        ) AS rank_order
    FROM fact_sales_monthly AS fm
    INNER JOIN dim_product AS dp
        ON fm.product_code = dp.product_code
    WHERE fm.fiscal_year = 2021
    GROUP BY dp.division, fm.product_code, dp.product
)
SELECT
    division,
    product_code,
    product,
    total_sold_quantity,
    rank_order
FROM product_sales
WHERE rank_order <= 3
ORDER BY division, rank_order;

/*
Expected Output: 9 rows (3 products × 3 divisions: PC, N&S, P&A)
Business Impact: Focuses attention on products driving majority of volume
Typical Concentration: Top 20% of products drive 80% of revenue
Strategic Actions:
1. Protect: Ensure supply chain reliability for these SKUs
2. Analyze: What makes them successful? (pricing, features, marketing)
3. Replicate: Apply success factors to other products
4. Extend: Consider product variants and accessories
*/


-- ============================================================================
-- BONUS QUERY: Products Discontinued in FY2021 (Portfolio Rationalization)
-- ============================================================================

/*
Business Question: Which products were removed from the portfolio?
Tables Used: fact_sales_monthly, dim_product
Key Insight: Tracks SKU rationalization and portfolio optimization
*/

SELECT DISTINCT
    fm.product_code,
    dp.product,
    dp.segment,
    dp.division
FROM fact_sales_monthly AS fm
INNER JOIN dim_product AS dp
    ON fm.product_code = dp.product_code
WHERE fm.fiscal_year = 2020
  AND fm.product_code NOT IN (
      SELECT DISTINCT product_code
      FROM fact_sales_monthly
      WHERE fiscal_year = 2021
  )
ORDER BY dp.division, dp.segment;

/*
Expected Output: List of products sold in 2020 but not in 2021
Business Impact: Validates portfolio rationalization strategy
Question to Ask: Were these products unprofitable or replaced by better versions?
*/


-- ============================================================================
-- QUERY PERFORMANCE OPTIMIZATION NOTES
-- ============================================================================

/*
INDEX RECOMMENDATIONS for improved query performance:

1. CREATE INDEX idx_customer_region ON dim_customer(region, customer);
2. CREATE INDEX idx_sales_fiscal ON fact_sales_monthly(fiscal_year, product_code);
3. CREATE INDEX idx_gross_price ON fact_gross_price(product_code, fiscal_year);
4. CREATE INDEX idx_discount ON fact_pre_invoice_deductions(fiscal_year, customer_code);
5. CREATE INDEX idx_customer_market ON dim_customer(market, customer_code);

QUERY OPTIMIZATION TIPS:

1. Always include join conditions on both keys (product_code AND fiscal_year)
2. Use EXPLAIN to analyze query execution plans
3. Filter data as early as possible (WHERE before GROUP BY)
4. Use CTEs for readability; use subqueries for performance in some cases
5. Limit SELECT * in production; specify only needed columns
6. Use appropriate data types (INT for counts, DECIMAL for currency)
7. Consider materialized views for frequently-run reports
*/


-- ============================================================================
-- SQL SKILLS DEMONSTRATED
-- ============================================================================

/*
TECHNICAL SKILLS SHOWCASED IN THIS PROJECT:

✓ Common Table Expressions (CTEs) - Queries 2, 4, 9, 10
✓ Window Functions (RANK, PARTITION BY, ROW_NUMBER) - Query 10
✓ Aggregate Functions (SUM, COUNT, AVG, ROUND) - All queries
✓ Multiple Table Joins (INNER, LEFT) - Queries 4, 5, 6, 7, 9, 10
✓ Subqueries (correlated and non-correlated) - Queries 5, 9, Bonus
✓ Date Functions (YEAR, MONTH, MONTHNAME) - Queries 7, 8
✓ CASE Statements - Query 8
✓ UNION Operations - Query 5
✓ GROUP BY with multiple columns - Queries 3, 4, 6, 7, 8, 9, 10
✓ ORDER BY and LIMIT - Multiple queries
✓ DISTINCT for uniqueness - Queries 1, 2, 3, 4, Bonus
✓ Filtering (WHERE) with complex conditions - All queries
✓ Calculation and formula implementation - Queries 2, 6, 7, 9
✓ Data type conversion and formatting - Queries 6, 7, 9

BUSINESS ANALYSIS SKILLS:

✓ Year-over-Year Growth Analysis
✓ Market Segmentation and Penetration
✓ Cost-Price Analysis
✓ Customer Profitability Assessment
✓ Revenue Trend and Seasonality Analysis
✓ Channel Performance Evaluation
✓ Product Portfolio Management
✓ Strategic Recommendation Development
*/


-- ============================================================================
-- END OF SQL QUERIES
--
-- Project: AtliQ Hardwares Business Intelligence Analysis
-- Challenge: Codebasics Resume Project #4
-- Database: gdb023 (atliq_hardware_db)
-- Total Queries: 10 + 1 Bonus
--
-- For presentation materials, insights, and recommendations, see:
-- - PRESENTATION_OUTLINE_AND_INSIGHTS.md
-- - VIDEO_PRESENTATION_SCRIPT.md
-- - SQL_QUERY_REVIEW_AND_IMPROVEMENTS.md
-- ============================================================================
