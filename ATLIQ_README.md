# 🍷 AtliQ Hardwares: Consumer Goods Ad-Hoc Insights

**Project Status:** Completed 
**Role:** Data Analyst
**Tools:** SQL (MySQL), Python (Matplotlib), Excel

---

## 📄 Project Overview
AtliQ Hardwares (a leading computer hardware producer) challenged us to answer **10 Ad-Hoc Business Questions** to provide insights for their executive team. The goal was to move beyond simple reporting and provide actionable strategic advice based on data.

**Key Objectives:**
1.  Analyze the `gdb023` database (Sales, Products, Customers).
2.  Identify growth areas (e.g., Which segment is booming?).
3.  Highlight risks (e.g., Over-dependence on specific retailers).

---

## 🔍 Key Insights & Findings

### 1. Product Expansion 🚀
*   **Insight:** The company launched **36% more unique products** in 2021 compared to 2020.
*   **Driver:** The **Accessories** segment was the biggest driver, growing by 49%.

![Product Growth](product_growth.png)

### 2. Market Reliance ⚠️
*   **Risk:** **Retailers** contribute **73%** of total gross sales, making AtliQ highly dependent on this single channel.
*   **Top Customers:** Managing relationships with giants like Amazon and Flipkart is critical, as they command high discounts (>30%).

![Channel Contribution](channel_chart.png)

### 3. Seasonality 📅
*   **Peak Period:** Sales consistently peak in **November** (Q1 of Fiscal Year), aligning with the festive season.
*   **Strategy:** Inventory planning must be optimized for July-August to meet this Sep-Nov demand spike.

![Sales Trend](monthly_sales_chart.png)

---

## 🛠️ Technical Solution
The core analysis was performed using complex SQL queries involving:
*   `JOIN`s across 4 tables (facts and dimensions).
*   `CTE`s (Common Table Expressions) for readable logic.
*   `Window Functions` (`RANK`, `DENSE_RANK`) for finding top products per division.

**📄 View the SQL Code:** [`atliq_consumer_goods_analysis.sql`](atliq_consumer_goods_analysis.sql)

---

## 📊 Dashboard Validation
As part of this project, I also prototyped an **Interactive Web Dashboard** to allow stakeholders to filter data in real-time.

![Dashboard Preview](dashboard_screenshot.png) *[Note: Upload your dashboard screenshot here if available]*

---

*Project executed as part of the Codebasics Resume Project Challenge.*
