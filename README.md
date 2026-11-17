# Colombian Fintech Customer & Transaction Analysis (2023)

An end-to-end data analytics project exploring customer behavior, financial product adoption, transaction activity, and estimated churn risk using Colombian fintech data.

## Project Overview

This project aims to analyze customer and transaction data to uncover business insights that can support customer segmentation, product strategy, and customer retention decisions.

The analysis follows an end-to-end workflow, starting with data exploration using Python, followed by SQL analysis in PostgreSQL, and interactive dashboard development in Power BI.

**Tools & Technologies**

- Python – Data exploration and preliminary analysis
- PostgreSQL – Data querying, transformation, and analysis
- Power BI – Interactive dashboard development
- Power Query – Data transformation and preparation

## Dataset

The dataset was obtained from Mendeley Data and consists of two main tables:

| Table | Description |
|---|---|
| `customers` | Customer demographics, location, customer segments, acquisition channels, financial product ownership, and customer metrics |
| `transactions` | Transaction records containing customer references, transaction dates, amounts, and transaction types |

**Dataset Overview**
- Approximately 48,723 customers
- Approximately 3.15 million transaction records
- Transaction period: January 4 – December 29, 2023

**Dataset Source:** [COFINFAD – Mendeley Data](https://doi.org/10.17632/mhb4zn3258.1)

## Business Objectives

The analysis focuses on answering the following business questions:

1. How are customers distributed across different customer segments and locations?
2. How does transaction activity change over time?
3. Which financial products are most widely adopted by customers?
4. How does transaction behavior differ across customer segments?
5. Which combinations of financial products are most common?
6. Which customer groups have higher estimated churn risk?
7. How many high-value customers are also classified as high churn risk?
8. Which acquisition channels have the highest number of customers classified as high churn risk?

## Dashboard Preview

The Power BI dashboard consists of three pages, each focusing on a different aspect of customer and transaction analysis.

### 1. Customer & Business Overview

Provides an overview of the customer base, transaction activity, and customer lifetime value.

**Key Metrics & Insights**
- Total Customers
- Total Transactions
- Total Transaction Amount
- Average Customer Lifetime Value
- Customer Distribution by Segment
- Monthly Transacting Customers
- Monthly Transaction Amount
- Average Customer Lifetime Value by Segment

<img width="12150" height="6900" alt="COFINFA dashboard_page-0001" src="https://github.com/user-attachments/assets/703d74eb-9ac7-4993-96d4-0927b277659a" />

### 2. Customer Behavior & Product Analysis

Explores customer engagement and adoption of financial products.

**Key Metrics & Insights**
- Total Customers
- Customers with Multiple Products
- Average Products per Customer
- Average Transactions per Customer
- Customer Adoption by Financial Product
- Product Adoption by Customer Segment
- Average Transactions by Customer Segment
- Most Common Product Combinations

<img width="12150" height="6900" alt="COFINFA dashboard_page-0002" src="https://github.com/user-attachments/assets/bc203c41-5aad-4212-a920-b6485958ddbc" />

### 3. Customer Retention & Churn Risk Analysis

Focuses on identifying customers with elevated estimated churn risk and prioritizing valuable customer groups.

**Key Metrics & Insights**
- Total Customers at Risk
- High-Risk Customers
- Average Churn Probability
- High-Value Customers at Risk
- Customer Distribution by Risk Category
- High-Risk Customers by Segment
- High-Value Customers at High Churn Risk
- High-Risk Customers by Acquisition Channel

<img width="12150" height="6900" alt="COFINFA dashboard_page-0003" src="https://github.com/user-attachments/assets/7f461da8-4687-42d4-b123-abcead0c1f03" />

**Interactive Filters:** Customer Segment, Location, and Acquisition Channel.

## Data Analysis Workflow

### 1. Data Exploration with Python
- Inspected dataset structure and data types.
- Explored customer attributes and transaction records.
- Performed preliminary data exploration to understand the dataset.

### 2. Data Analysis with PostgreSQL
- Queried and analyzed customer and transaction data.
- Aggregated transaction activity by customer segment and time period.
- Analyzed financial product adoption and product combinations.
- Examined customer lifetime value and estimated churn probability.
- Prepared analytical outputs for Power BI.

### 3. Data Transformation with Power Query
- Transformed financial product ownership columns from wide format into long format.
- Prepared product adoption data for visualization.
- Organized analytical data for dashboard development.

### 4. Dashboard Development with Power BI
- Created calculated columns and DAX measures.
- Developed KPI cards and interactive visualizations.
- Added slicers to explore customer behavior by segment, location, and acquisition channel.

## Key Methodological Considerations

- **Churn Probability:** The dataset provides an estimated churn probability score, not verified customer churn outcomes. Therefore, this project analyzes estimated churn risk rather than actual churn rates.
- **Risk Categorization:** Customers are classified into four risk categories using quartile-based thresholds derived from the churn probability distribution.
- **Customer Lifetime Value (CLV):** CLV is treated as a customer value metric provided by the dataset, not automatically as realized revenue or profit.
- **CLV Categorization:** Customers are grouped into four categories using quartile-based thresholds derived from the CLV distribution.
- **Transaction Amount:** Transaction amounts are analyzed as recorded in the dataset. Negative and zero-value transactions should not automatically be interpreted as revenue.

## Repository Structure

```text
colombian-fintech-analysis/
│
├── data/
│   └── README.md
│
├── notebooks/
│   └── data_exploration.ipynb
│
├── sql/
│   └── analysis.sql
│
├── dashboard/
│   ├── dashboard_page_1.png
│   ├── dashboard_page_2.png
│   └── dashboard_page_3.png
│
└── README.md
```

*The repository structure above is a suggested layout and should be adjusted to match the actual files.*

## Conclusion

This project demonstrates an end-to-end data analytics workflow, combining Python, PostgreSQL, and Power BI to analyze customer behavior and transaction activity.

The analysis provides insights into customer segmentation, financial product adoption, transaction patterns, customer value, and estimated churn risk.

These insights can support data-driven decisions related to customer engagement, product strategy, and retention prioritization.

---

**Author:** Rafi Alghifari  
