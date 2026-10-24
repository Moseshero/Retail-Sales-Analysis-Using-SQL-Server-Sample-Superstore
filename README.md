# Retail Sales Analysis Using SQL Server | Sample Superstore

## Project Overview

This project analyzes retail sales transactions using **Microsoft SQL Server and Transact-SQL (T-SQL)** to evaluate sales performance, profitability, customer purchasing behavior, product performance, regional performance, and the relationship between discounts and profit.

Using the Sample Superstore dataset, I developed and executed SQL queries to transform raw transaction data into actionable business insights. The analysis focuses not only on revenue generation but also on identifying areas where high sales do not necessarily translate into strong profitability.

The project demonstrates my ability to use SQL for data exploration, data quality assessment, aggregation, ranking, segmentation, and business performance analysis.

## Business Problem

Retail businesses need to understand which products, customers, regions, and business segments contribute most to revenue and profit. However, high sales figures alone do not guarantee strong financial performance.

Management needs answers to questions such as:

- How much revenue and profit does the business generate?
- Which product categories and subcategories perform best?
- Which regions contribute most to sales and profitability?
- Are sales growing year over year?
- Which customers generate the highest revenue?
- Which products generate the most sales within each category?
- How are different discount levels associated with profitability?
- Are there data quality issues that could affect reporting?

This project addresses these questions through structured SQL analysis.

## Project Objectives

1. Assess overall retail sales and profitability.
2. Evaluate sales and profit performance across product categories and subcategories.
3. Compare regional performance using sales, profit, and profit margin.
4. Analyze annual sales trends and year-over-year growth.
5. Identify the highest-revenue customers and products.
6. Investigate the relationship between discount levels and profitability.
7. Check the dataset for duplicates, missing values, and date inconsistencies.
8. Translate analytical results into practical business recommendations.

## Tools and Technologies

- **Microsoft SQL Server** — relational database management.
- **SQL Server Management Studio (SSMS)** — SQL development and query execution environment.
- **Transact-SQL (T-SQL)** — data exploration, transformation, aggregation, and analysis.
- **CSV** — source data format and exported analytical results.
- **GitHub** — project documentation and version control.

## Dataset Description

The project uses the Sample Superstore retail dataset, containing order-level transaction details, customer information, product information, shipping dates, sales, discounts, and profit. The dataset is downloaded from Kaggle platform.

### Dataset summary

| Metric | Result |
| --- | ---: |
| Total transaction line items | 9,994 |
| Unique orders | 5,009 |
| Unique customers | 793 |
| Unique products | 1,862 |
| Total units sold | 37,873 |
| Total sales | $2,297,200.86 |
| Total recorded profit | $286,817.02 |
| Overall profit margin | 12.49% |
| Analysis period | 2014–2017 |

*Note: Profit totals exclude one missing Profit value because SQL's* *`SUM()`* *function ignores* *`NULL`* *values. The reported profit margin is calculated as total recorded profit divided by total sales.*

### Key data fields

The dataset includes fields such as:

- **Order information:** `Row_ID`, `Order_ID`, `Order_date`, `Ship_date`, `Ship_mode`
- **Customer information:** `Customer_ID`, `Customer_name`, `Segment`
- **Geographical information:** `Country`, `City`, `State`, `Region`, `Postal_code`
- **Product information:** `Product_ID`, `Category`, `Sub_Category`, `Product_name`
- **Financial information:** `Sales`, `Quantity`, `Discount`, `Profit`

## Database Setup

The dataset was imported into Microsoft SQL Server and stored in the following database and table:

- **Database:** `RetailSalesDB`
- **Table:** `dbo.SuperstoreSales`

The analysis was performed using T-SQL queries in SSMS.

Example query to inspect the dataset:

``` sql
SELECT TOP (10) *
FROM dbo.SuperstoreSales;
```

## SQL Skills Demonstrated

The project covers multiple SQL techniques used in practical data analysis:

- Data exploration using `SELECT` and `TOP`
- Data quality checks using `COUNT`, `COUNT(DISTINCT ...)`, `IS NULL`, and duplicate detection
- Aggregation using `SUM`, `AVG`, `MIN`, and `MAX`
- Grouping and segmentation using `GROUP BY`
- Filtering and conditional logic using `WHERE`, `HAVING`, and `CASE`
- Sorting and prioritization using `ORDER BY`
- Common Table Expressions (CTEs)
- Window functions, including `ROW_NUMBER()`
- Ranking customers and products
- Calculating percentage contribution and profit margins
- Year-over-year sales growth analysis
- Discount-band and profitability analysis
- Date validation and shipping-duration analysis

## Analysis and Key Findings

### 1\. Overall Sales and Profitability

The business generated approximately **$2.30 million in sales** and **$286,817 in recorded profit** across 9,994 transaction line items.

The overall profit margin was approximately **12.49%**.

**Business insight:** Revenue provides an important measure of business scale, but profitability and margin are necessary to evaluate the quality of that revenue.

### 2\. Product Category Performance

| Category | Total Sales | Total Profit | Profit Margin |
| --- | ---: | ---: | ---: |
| Technology | $836,154.03 | \~$145,455 | 17.40% |
| Furniture | $741,999.79 | $18,871 | 2.54% |


Technology generated the highest sales among the three categories and delivered the strongest reported profit margin.

Furniture generated substantial revenue but achieved a much lower margin of approximately 2.54%.

**Business insight:** Furniture warrants closer examination because its high sales volume does not translate into comparable profitability.

### 3\. Regional Performance

| Region | Total Sales | Total Profit | Profit Margin |
| --- | ---: | ---: | ---: |
| West | $725,457.82 | $108,418.45 | 14.94% |
| East | $678,781.24 | $91,522.78 | 13.48% |
| South | $391,721.91 | $47,169.43 | 12.04% |
| Central | $501,239.89 | $39,706.36 | 7.92% |

The West generated the highest sales and profit, while the Central region recorded the lowest profit margin among the four regions.

**Business insight:** Regional sales volume and profitability should be assessed together. The Central region may benefit from a more detailed review of product mix, discounts, shipping costs, and other relevant expenses.

### 4\. Annual Sales Trend

| Year | Total Sales | Year-over-Year Growth |
| --- | ---: | ---: |
| 2014 | $484,247.50 | — |
| 2015 | $470,532.51 | -2.83% |
| 2016 | $609,205.60 | +29.47% |
| 2017 | $733,215.25 | +20.36% |

Sales declined slightly in 2015 before recovering strongly in 2016 and continuing to grow in 2017.

By 2017, annual sales were approximately **51.4% higher than in 2014**.

**Business insight:** The business experienced strong sales growth in the latter part of the analysis period. Further analysis could investigate which product categories, regions, and customer segments contributed most to this growth.

### 5\. Discount and Profitability Analysis

The discount analysis revealed a notable relationship between discount levels and recorded profitability.

- Transactions with no discount generated approximately **$320,987.60 in profit**.
- Transactions with discounts greater than 30% collectively recorded a loss of approximately **$134,956.05**.
- The discount group above 50% recorded a profit margin of approximately **-119.20%**.

**Business insight:** Higher discount levels were associated with weaker profitability in the analyzed data. Management should review discount policies, particularly for heavily discounted products and transactions.

**Important limitation:** These results show an association, not proof that discounts alone caused the losses. Product mix, costs, transaction characteristics, and other factors may also influence profitability.

### 6\. Loss-Making Product Subcategories

Three subcategories recorded negative total profit:

| Subcategory | Total Sales | Total Profit |
| --- | ---: | ---: |
| Tables | $206,965.53 | -$17,305.48 |
| Bookcases | $114,880.00 | -$3,472.56 |
| Supplies | $46,673.54 | -$1,189.10 |

Tables recorded the largest loss among these subcategories despite generating more than $200,000 in sales.

**Business insight:** Products with substantial sales but negative profit deserve priority in profitability reviews. Possible areas to investigate include discounting, pricing, procurement costs, and shipping expenses.

### 7\. Top 10 Customers by Sales

The customer-ranking query identified the ten customers with the highest total sales.

| Rank | Customer | Total Sales | Share of Overall Sales |
| ---: | --- | ---: | ---: |
| 1 | Sean Miller | $25,043.05 | 1.09% |
| 2 | Tamara Chand | $19,052.22 | 0.83% |
| 3 | Raymond Buch | $15,117.34 | 0.66% |
| 4 | Tom Ashbrook | $14,595.62 | 0.64% |
| 5 | Adrian Barton | $14,473.57 | 0.63% |
| 6 | Ken Lonsdale | $14,175.23 | 0.62% |
| 7 | Sanjit Chand | $14,142.33 | 0.62% |
| 8 | Hunter Lopez | $12,873.30 | 0.56% |
| 9 | Sanjit Engle | $12,209.44 | 0.53% |
| 10 | Christopher Conant | $12,129.07 | 0.53% |

Sean Miller ranked first, contributing approximately 1.09% of total sales.

**Business insight:** Customer ranking can help businesses identify high-revenue customers for retention analysis and targeted engagement. However, sales contribution alone does not establish customer profitability or loyalty.

### 8\. Top Products Within Each Category

A window-function query ranked products by total sales within each product category, returning the top ten products for Furniture, Office Supplies, and Technology.

Selected results included:

| Category | Product | Total Sales | Total Profit |
| --- | --- | ---: | ---: |
| Furniture | HON 5400 Series Task Chairs for Big and Tall | $21,870.58 | $0.00 |
| Furniture | Riverside Palais Royal Lawyers Bookcase | $15,610.97 | -$669.54 |
| Office Supplies | Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | $27,453.38 | $7,753.04 |
| Office Supplies | GBC DocuBind TL300 | $19,823.48 | $2,233.51 |
| Technology | Canon imageCLASS 2200 Advanced Copier | $61,599.82 | $25,199.93 |
| Technology | Cisco TelePresence System EX90 | $22,638.48 | -$1,811.08 |

**Business insight:** Product rankings reveal that high sales do not always imply high profit. For example, the Cisco TelePresence System EX90 generated substantial sales but recorded a loss. Product-level sales and profit should therefore be evaluated together.

### 9\. Data Quality Assessment

The data quality checks identified the following:

- **Duplicate row identifiers:** No duplicate `Row_ID` values were found.
- **Missing values:** One `Profit` value was missing.
- **Date parsing:** No unparseable order or shipping dates were reported.
- **Date consistency:** No shipping dates earlier than their corresponding order dates were found.

**Business insight:** Data quality checks help establish confidence in analytical results. The missing profit value should be investigated before any downstream reporting that requires complete profit records.

## Business Recommendations

Based on the analysis, the following actions are recommended:

1. **Review Furniture profitability.** Investigate pricing, discounting, and cost structures to understand why the category has a relatively low margin despite high sales.
2. **Evaluate high-discount transactions.** Review the profitability of heavily discounted products and introduce margin-based controls where appropriate.
3. **Investigate loss-making subcategories.** Conduct a deeper analysis of Tables, Bookcases, and Supplies to identify the drivers of negative profit.
4. **Study regional differences.** Examine why the Central region has a lower profit margin than other regions, considering product mix, discounts, and available cost data.
5. **Protect profitable product lines.** Use product-level margin analysis alongside sales rankings when making inventory and promotional decisions.
6. **Strengthen customer analysis.** Combine customer sales rankings with purchase frequency, profit contribution, and repeat-purchase behavior to support customer-retention strategies.
7. **Investigate sales growth drivers.** Break down the growth recorded in 2016 and 2017 by category, region, and customer segment.
8. **Improve data completeness.** Investigate the missing Profit value and document the treatment of missing data in future reporting.

These are recommendations for further investigation and decision-making, not claims that the dataset establishes the causes of the observed results.

## Project Workflow

The project followed this analytical workflow:

1. **Data import:** Imported the Sample Superstore CSV file into SQL Server.
2. **Database setup:** Stored the data in `RetailSalesDB.dbo.SuperstoreSales`.
3. **Data exploration:** Examined the table structure, transaction records, and key fields.
4. **Data quality checks:** Assessed duplicate row identifiers, missing values, and date consistency.
5. **SQL analysis:** Developed queries to calculate KPIs, compare performance, analyze trends, and rank customers and products.
6. **Results export:** Exported query results to CSV files for review and documentation.
7. **Business interpretation:** Summarized key findings and developed recommendations based on the results.

## Repository Structure

A suggested structure for this GitHub repository is:

``` text
sample-superstore-sql-analysis/
│
├── README.md
│
├── data/
│   └── Sample_Superstore.csv
│
├── sql/
│   └── sql_superstore_analysis.sql
│
└── results/
    ├── sql_superstore_analysis_Resultsce.csv

```


## Limitations

- The analysis is based on the fields available in the Sample Superstore dataset.
- One Profit value is missing, and the reported total profit excludes that record's missing value.
- The dataset covers 2014–2017 and does not describe current retail market conditions.
- Observed relationships between discounts and profit do not establish causation.
- Customer rankings are based on revenue, not customer lifetime value or profitability.
- Recommendations should be validated with additional cost, pricing, inventory, and operational data before implementation.

## Conclusion

This project demonstrates how SQL Server can be used to extract business insights from retail transaction data.

The analysis identified overall performance metrics, differences in category and regional profitability, annual sales growth, heavily discounted transactions associated with losses, loss-making product subcategories, and high-revenue customers and products.

The key takeaway is that **revenue growth should be evaluated alongside profitability**. Businesses can make better-informed decisions when sales, margins, customer behavior, product performance, and data quality are examined together.

## Skills Demonstrated

`SQL` · `T-SQL` · `Microsoft SQL Server` · `SSMS` · `Data Analysis` · `Data Cleaning & Validation` · `CTEs` · `Window Functions` · `Business Intelligence` · `KPI Analysis` · `Profitability Analysis` · `Data-Driven Decision Making`

## Author

**Data Analyst Portfolio Project**

This project is part of my portfolio demonstrating practical data analysis skills using SQL and other analytical tools.

For more projects, explore my GitHub profile: [github.com/moseshero](<https://github.com/moseshero>)
