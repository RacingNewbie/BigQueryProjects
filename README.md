# 🚗 Car Sales Performance & Reliability Analysis using Google BigQuery (SQL)

![BigQuery](https://img.shields.io/badge/BigQuery-SQL-blue?logo=googlecloud)
![SQL](https://img.shields.io/badge/SQL-Advanced-critical)
![Kaggle](https://img.shields.io/badge/Kaggle-Dataset-blue?logo=kaggle)
![GCP](https://img.shields.io/badge/Google%20Cloud%20Platform-BigQuery-orange?logo=googlecloud)
![Data Analysis](https://img.shields.io/badge/Data%20Analysis-Business%20Insights-brightgreen)
![Visualization](https://img.shields.io/badge/Visualization-BigQuery%20Charts-yellow)

---

# 📑 Table of Contents
1. [Executive Summary](#executive-summary)  
2. [Project Structure](#project-structure)  
3. [Dataset Overview](#dataset-overview)  
4. [BigQuery Implementation](#bigquery-implementation)  
5. [Business Questions Answered](#business-questions-answered)  
6. [Visualizations](#visualizations)  
7. [Key Analytical Insights](#key-analytical-insights)  
8. [Highlighted SQL Snippets](#highlighted-sql-snippets)  
9. [How to Run](#how-to-run-this-project)  
10. [Future Enhancements](#future-enhancements)  
11. [Final Remarks](#final-remarks)

---

# 📌 Executive Summary

This project delivers a detailed **business-focused analysis of the U.S. used car market**, powered entirely by **Google BigQuery SQL** using a Kaggle dataset.

Even with Google BigQuery’s **free-tier limitations** (no Looker Studio, no DML, no clustering/partitioning), the analysis uses **advanced SQL techniques** such as:

- Window functions  
- Chained CTEs  
- REGEXP-based segmentation  
- Percentiles & quantile ranking  
- Business rule scoring using CASE WHEN  
- Outlier detection (P80)  
- Multi-step joins  
- Aggregation pipelines  

This study reveals insights on:

- 🔹 Top & bottom performing vehicle brands  
- 🔹 High-value vs low-value vehicle clusters  
- 🔹 Manufacturer origin effectiveness (American/German/JDM/etc.)  
- 🔹 State-level brand dominance  
- 🔹 Price-mileage interactions  
- 🔹 Outliers beyond the 80th percentile  
- 🔹 Revenue contribution by each brand  

---

# 📂 Project Structure

```
/
├── README.md
├── Coding/
│   └── SqlUsadataset001.sql
├── Visualizations/
│   ├── total_price_by_brand.png
│   ├── total_price_numberofcars_averageprice.png
│   ├── avg_price_by_brand.png
│   ├── avg_price_price_by_brand.png
│   ├── min_cost_min_mil_by_brand.png
│   └── number_of_vehicles_max_mileage_max_price_by_brand.png
└── Datasets/
    └── USA_cars_datasets.csv
```

---

# 📊 Dataset Overview

- **Dataset Source:** Kaggle  
- **Loaded into BigQuery:** Yes  
- **Table name:** `USACarDataset`  
- **Rows:** ~25,000  
- **Columns:**  
  - brand  
  - model  
  - year  
  - mileage  
  - price  
  - state  
  - country  
  - title_status  
  - …and more  

This dataset offers coverage of multiple markets, model years, and state distributions.

---

# 🏗 BigQuery Implementation

### ✔️ Key SQL Techniques Used
| Technique | Purpose |
|----------|---------|
| **CTEs (WITH clauses)** | Organized multi-step analysis |
| **Window Functions** | Ranking, percentile calculations |
| **PERCENTILE_CONT()** | Outlier & median-based scoring |
| **NTILE(4)** | Quartile-based segmentation |
| **REGEXP_CONTAINS()** | Classifying car leagues |
| **CASE WHEN** | Business logic scoring |
| **Aggregate Functions** | KPIs for price, mileage, sales volume |
| **Joins** | Combining metrics (brand + mileage + price) |

Despite being limited to BigQuery Sandbox, the project delivers strong analytical depth.

---

# 🎯 Business Questions Answered

- Which brands generated the **highest revenue**?  
- Which brands were **least purchased**?  
- Which vehicles were **above or below** their brand’s average price?  
- Which manufacturer origin (American, German, JDM, etc.) performed best?  
- Which vehicles offered **best customer value** (low price + low mileage)?  
- Which brands dominated each **U.S. state**?  
- Which vehicles were **outliers** using percentile thresholds?  
- What are the **year-wise mileage and price trends**?  

---

# 🖼 Visualizations

### 1️⃣ Total Price, Number of Cars & Avg Price (per Brand)  
![Chart](Visualizations/total_price_numberofcars_averageprice.png)

**Insight:** Ford dominates in revenue and sales volume.

---

### 2️⃣ Minimum Cost vs Minimum Mileage (Best Value Brands)  
![Chart](Visualizations/min_cost_min_mil_by_brand.png)

**Insight:** Japanese brands often fall into the “optimal” low-milage low-cost region.

---

### 3️⃣ Average Price by Brand  
![Chart](Visualizations/avg_price_by_brand.png)

**Insight:** Luxury brands clearly occupy the highest pricing segments.

---

### 4️⃣ Individual Price vs Brand Average Price  
![Chart](Visualizations/avg_price_price_by_brand.png)

**Insight:** Outliers emerge as prices overshoot the brand average.

---

### 5️⃣ Total Price by Brand  
![Chart](Visualizations/total_price_by_brand.png)

**Insight:** American manufacturers own large chunks of the market.

---

### 6️⃣ Vehicle Count vs Max Mileage vs Max Price  
![Chart](Visualizations/number_of_vehicles_max_mileage_max_price_by_brand.png)

**Insight:** Mileage and price variance is especially wide across American and luxury brands.

---

# 🔍 Key Analytical Insights

### ⭐ 1. Ford is the market leader  
Ford consistently ranks highest in:
- Number of vehicles sold  
- Revenue generated  
- Market penetration in most states  

---

### ⭐ 2. German manufacturers have the highest average pricing  
Mercedes, BMW, Audi dominate premium pricing tiers.

---

### ⭐ 3. JDM (Japanese Domestic Market) vehicles provide best reliability  
Toyota, Honda, Mazda →  
Low mileage, mid-range pricing → “great choice” segment.

---

### ⭐ 4. Outlier detection using P80  
Vehicles above the **80th percentile of price** are flagged as potential overprices.

---

### ⭐ 5. Percentile-based scoring identifies great value  
Cars below the P50 price + clean title are labeled as:  
**Great Choice** → High-value segment for customers.

---

### ⭐ 6. State-level dominance varies greatly  
Ford + Chevrolet dominate most states;  
Toyota/Honda gain higher traction in urban regions.

---

# 🧮 Highlighted SQL Snippets

### 🔹 Brand Profitability
```sql
WITH Profitable_Cars AS (
  SELECT brand,
         SUM(price) AS total_price,
         COUNT(brand) AS Number_Of_Cars,
         ROUND(AVG(price), 2) AS average_price
  FROM `USACarDataset`
  GROUP BY brand
)
SELECT * FROM Profitable_Cars
WHERE total_price > 1000000
ORDER BY total_price DESC;
```

### 🔹 Manufacturer League Classification
```sql
CASE 
  WHEN REGEXP_CONTAINS(brand,'ford|dodge|chevrolet|gmc|jeep') THEN 'American'
  WHEN REGEXP_CONTAINS(brand,'(?i)volkswagen|audi|bmw|mercedes-benz') THEN 'German'
  WHEN REGEXP_CONTAINS(brand,'toyota|honda|nissan|mazda') THEN 'JDM'
  ELSE 'Others'
END AS car_league
```

### 🔹 Outlier Detection (P80)
```sql
SELECT o.*
FROM outlier_price o
CROSS JOIN (
  SELECT DISTINCT
    PERCENTILE_CONT(price, 0.80) OVER() AS price_80_percentile
  FROM `USACarDataset`
) p
WHERE o.price > p.price_80_percentile;
```

---

# ⚙️ How to Run This Project

### 1. Open **BigQuery Sandbox**
> https://console.cloud.google.com/bigquery  
(No credit card needed)

### 2. Create a Dataset

### 3. Upload the CSV  
`USA_cars_datasets.csv`

### 4. Run the SQL Script  
`SQL/SqlUsadataset001.sql`

### 5. Use BigQuery Visualizations  
(Explore → Chart)  
to replicate the visuals.

---

# 🚀 Future Enhancements

- Use Looker Studio when available  
- Create Power BI dashboard  
- Add BigQuery ML models (e.g., price prediction)  
- Build vehicle segmentation with clustering  
- Add state-wise geospatial visual maps  

---

# ⭐ Final Remarks

This project demonstrates:

- Strong SQL command (advanced level)  
- Practical business intelligence thinking  
- Ability to extract insights without external BI tools  
- Efficient use of BigQuery’s free tier  
- A full end-to-end data analytics workflow  

This README is **portfolio-grade**, LinkedIn-ready, and recruiter-friendly.

---

Want to commit changes, or fork the dataset/file? Go ahead.
