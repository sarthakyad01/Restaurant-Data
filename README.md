# 🍽️ Restaurant Customer & Revenue Analytics (SQL - SQLite)

![SQL](https://img.shields.io/badge/SQL-SQLite-blue)
![DB](https://img.shields.io/badge/Database-SQLite-lightgrey)
![Status](https://img.shields.io/badge/Project-Completed-brightgreen)
![Focus](https://img.shields.io/badge/Domain-Restaurant%20Analytics-purple)
![Tech](https://img.shields.io/badge/Tech-SQL%20%7C%20Analytics%20%7C%20Data%20Modeling-blue)

---

## 📌 Project Overview  
This project performs end-to-end analysis of a restaurant database using **SQLite**, focusing on customer behavior, menu performance, and revenue optimization.

The goal is to simulate real-world restaurant analytics (similar to platforms like Uber Eats and DoorDash) by leveraging SQL to extract insights that drive **business decisions, customer retention, and profitability**.

---

## 🎯 Business Problem  

Restaurants generate large amounts of transactional and operational data but often lack structured insights.

👉 **Key Questions:**  
- Which menu items drive the most revenue?  
- Who are the highest-value customers?  
- How often do customers return?  
- Do reservations and events increase customer engagement?  

---

## 📊 Dataset  

- **Source:** Open-source SQLite restaurant database  
- **Tables Used:**
  - `Customers`
  - `Orders`
  - `OrdersDishes`
  - `Dishes`
  - `Reservations`
  - `Events`
  - `CustomersEvents`

### Key Data Features:
- Customer demographics and preferences  
- Order-level transactional data  
- Dish-level pricing and menu categories  
- Reservation and event participation data  

---

## 🛠️ Tech Stack  

- **SQL (SQLite)**  
- **DB Browser for SQLite**  
- **Data Modeling & Query Optimization**  

---

## 🔍 Methodology  

### 1. Data Exploration & Understanding  
- Analyzed schema relationships across multiple tables  
- Identified primary and foreign keys for joins  
- Validated assumptions (e.g., one row per dish per order)

---

### 2. Data Transformation & Querying  
- Built complex queries using:
  - Joins across multiple tables  
  - Aggregations (`SUM`, `COUNT`, `AVG`)  
  - Subqueries and Common Table Expressions (CTEs)  
  - Window functions (`RANK`, `ROW_NUMBER`, `SUM OVER`)  

---

### 3. KPI Development  

Computed key business metrics:

- **Total Revenue**
- **Average Order Value (AOV)**
- **Customer Lifetime Value (CLV)**
- **Repeat Purchase Rate**
- **Reservation-to-Order Conversion**
- **Event Engagement Metrics**

---

### 4. Advanced Analytics  

Implemented:

- **Cohort Analysis** → Customer retention trends  
- **RFM Segmentation** → Customer value classification  
- **Pareto Analysis (80/20 Rule)** → Revenue concentration  
- **Menu Engineering** → Dish popularity vs profitability  
- **Customer Behavior Analysis** → Ordering patterns  

---

## 📈 Key Results  

### 🏆 Revenue Insights  
- A small subset of dishes contributes to a **majority of total revenue**  
- High-priced items are not always the most frequently ordered  

---

### 👥 Customer Insights  
- Top 20% of customers contribute to a **significant portion of revenue (Pareto effect)**  
- Repeat customers drive **higher lifetime value and consistency in revenue**  

---

### 🍽️ Menu Insights  
- Identified **“Star” dishes** (high popularity + high revenue)  
- Identified **underperforming items** with low demand  

---

### 📅 Operational Insights  
- Reservations show a **strong correlation with future orders**  
- Events increase **customer engagement and repeat visits**  

---

## 💡 Business Recommendations  

- 📈 Promote high-performing (“Star”) menu items  
- 🔁 Retarget high-value customers using loyalty strategies  
- 🍽️ Optimize menu by removing or improving low-performing dishes  
- 📊 Leverage reservation data for predictive demand planning  
- 🎉 Expand event-driven engagement strategies  

---

## 📊 Additional Insights  

- Average Order Value (AOV) varies significantly across customers  
- Customer segmentation reveals **high-value vs at-risk users**  
- Revenue distribution is **skewed toward a small group of customers and dishes**  

---

## 💡 Business Impact  

- 📈 Enables **data-driven menu optimization**  
- 🎯 Improves **customer retention and targeting strategies**  
- 💰 Identifies key drivers of **revenue and profitability**  
- 🔁 Establishes a **repeatable SQL analytics framework**  

---

## 🧠 Skills Demonstrated  

- Advanced SQL (Joins, CTEs, Window Functions)  
- Data Modeling & Relational Analysis  
- Customer Segmentation (RFM)  
- Cohort & Retention Analysis  
- Business KPI Development  
- Analytical Thinking & Insight Generation  

---

## 🔮 Future Improvements  

- Build a **Power BI / Tableau dashboard** for visualization  
- Implement **predictive modeling (customer churn / demand forecasting)**  
- Add **time-series forecasting for sales trends**  
- Integrate marketing data for **campaign effectiveness analysis**  

---
