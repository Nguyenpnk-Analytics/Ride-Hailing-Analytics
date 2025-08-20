# 🚖 Uber Ride-Hailing Expansion Analysis

## 📖 Project Overview
This project analyses an **Uber ride-hailing dataset** to uncover demand patterns, customer behaviour, and geographic opportunities.  
The goal is to generate actionable business insights, visualise them through dashboards and reports, and provide recommendations for Uber’s potential **market expansion** across the United States.

---

## 📂 Dataset

- **Source**: [Uber Data Analysis (Kaggle)](https://www.kaggle.com/datasets/bhanupratapbiswas/uber-data-analysis)  
- **Size**: ~650K trips across multiple states.  
- **Description**: This dataset contains Uber trip records, including location, date/time, and ride purpose. It enables analysis of travel trends across states, time-based demand, and ride purposes.  

### 🔑 Main Fields
- `start_date` – Trip start time.  
- `end_date` – Trip end time.  
- `category` – Ride purpose (e.g. Business, Commute, Errand).  
- `start` – Starting location.  
- `stop` – Ending location.  
- `miles` – Distance of trip.  
- `state` – State where the trip occurred.  

### 📊 Data Characteristics
- Covers **daily and hourly ride patterns** across states.  
- Allows analysis of:  
  - **Trip demand distribution** by geography.  
  - **Peak-hour usage** and commuting trends.  
  - **Customer behaviour** by purpose (commute vs. leisure).  
  - **Emerging vs. saturated markets** for Uber expansion.  

### 🧹 Data Cleaning & Preparation
- Removed duplicates and null values in `start_date`, `state`, and `miles`.  
- Standardised time formats and extracted **hourly/weekly** components.  
- Applied Power Query transformations for aggregation by **state and category**.  

---

## 🔎 Workflow

1. **Exploratory Data Analysis (EDA)**  
   - Monitored ride distribution by **time, location, and purpose**.  
   - Identified high-demand vs. low-demand states.  
   - Analysed peak travel hours and weekday/weekend variations.  
   - Compared saturated markets vs. emerging growth markets.  

2. **Business Questions**  
   - How many trips have been recorded, and what is their distribution?  
   - What are the main booking trends across time and purpose?  
   - Which states/cities are highly active but close to saturation?  
   - Which states offer growth potential based on GDP, demographics, and geography?  

3. **Tools Used**  
   - **Power Query** → Data cleaning, transformation.  
   - **Power BI** → Interactive dashboard creation and storytelling visualisation.  
   - **Markdown / PDF** → Documentation and reporting.  

---

## 📊 Key Insights

- **Overall Ride Activity**  
  - Over **650K trips** recorded in the dataset.  
  - **New York, New Jersey, and California** dominate trip volume but show signs of **market saturation**.  

- **Time & Demand Patterns**  
  - Clear peaks: **07:00–09:00** and **17:00–19:00** (commute hours).  
  - **Weekdays** drive the majority of rides; weekends show more leisure trips.  

- **Geographic Insights**  
  - **High-activity hubs**: NY, NJ, CA – strong but nearing maturity.  
  - **Emerging markets**: **Texas, Florida, Washington** – large populations, high GDP, and strategic coastal access.  

- **Customer Behaviour**  
  - **Commute trips** dominate usage.  
  - **Leisure/tourism trips** steady during weekends and holidays → potential in tourism-heavy states.  

### 💡 Recommendations
- Target **Texas, Florida, and Washington** as priority regions for growth.  
- Optimise **driver allocation & surge pricing** at commute peaks.  
- Run **weekend promotions** in tourism-driven markets.  
- Treat mature hubs (NY, CA) as **cash cows**, reinvesting gains into emerging states.  

---

## 📈 Dashboard & Visualisation

- **Power BI dashboard (PDF)**: highlights demand trends and expansion opportunities.  
- **Preview (static image):**  
  ![Dashboard Preview](assets/uber_dashboard.png)  

---

## ⚙️ Usage

- Open `Uber_Ride_Expansion.pbix` with **Power BI Desktop**.  
- Explore the **PDF dashboard export** for static insights.  
- Dataset available on [Kaggle](https://www.kaggle.com/datasets/bhanupratapbiswas/uber-data-analysis).  
