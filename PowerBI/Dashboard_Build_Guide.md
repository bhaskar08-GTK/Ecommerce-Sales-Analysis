# Power BI Dashboard — Build Guide

Step-by-step instructions to recreate the interactive dashboard in Power BI Desktop (~15 minutes).

---

## 1. Import Data

1. Open **Power BI Desktop**
2. Click **Get Data → Excel Workbook**
3. Navigate to `Excel/Cleaned_Data.xlsx` → select the table → **Load**
4. In the **Data** pane (right side), verify all 21 columns loaded

## 2. Data Type Checks (Power Query)

1. Click **Transform Data** (ribbon)
2. Verify types:
   - `Order Date`, `Ship Date` → **Date**
   - `Sales`, `Profit` → **Decimal Number**
   - `Discount` → **Decimal Number**
   - `Quantity` → **Whole Number**
3. Click **Close & Apply**

---

## 3. Create Measures (DAX)

Go to **Modeling → New Measure** and add these one by one:

```dax
Total Sales = SUM('Cleaned_Data'[Sales])
```

```dax
Total Profit = SUM('Cleaned_Data'[Profit])
```

```dax
Total Orders = DISTINCTCOUNT('Cleaned_Data'[Order ID])
```

```dax
Profit Margin = DIVIDE([Total Profit], [Total Sales], 0)
```

```dax
Avg Order Value = DIVIDE([Total Sales], [Total Orders], 0)
```

---

## 4. Page 1 — Overview Dashboard

### Layout (top to bottom, left to right):

### 4a. KPI Cards (top row — 4 cards)

| Card | Value | Format |
|------|-------|--------|
| Card 1 | `[Total Sales]` | Currency, 0 decimals |
| Card 2 | `[Total Profit]` | Currency, 0 decimals |
| Card 3 | `[Total Orders]` | Whole number |
| Card 4 | `[Profit Margin]` | Percentage, 2 decimals |

**How**: Insert → Card visual → drag the measure to the **Fields** well → format the display.

### 4b. Monthly Sales Trend (middle-left)

- Visual: **Line Chart**
- X-axis: `Order Date` (set to **Month** hierarchy: Year → Month)
- Y-axis: `[Total Sales]`
- Optional: Add `[Total Profit]` as a second line
- Format: Line color → Teal (#00B4D8)

### 4c. Sales by Region (middle-right)

- Visual: **Clustered Bar Chart**
- Y-axis: `Region`
- X-axis: `[Total Sales]`
- Sort: Descending by `[Total Sales]`
- Data colors: Use a gradient from teal to light blue

### 4d. Sales & Profit by Category (bottom-left)

- Visual: **Clustered Bar Chart**
- Y-axis: `Category`
- X-axis: `[Total Sales]` AND `[Total Profit]`
- Colors: Sales = Teal, Profit = Orange

### 4e. Sales by Segment — Donut (bottom-right)

- Visual: **Donut Chart**
- Legend: `Segment`
- Values: `[Total Sales]`
- Colors: Consumer = Teal, Corporate = Blue, Home Office = Orange

### 4f. Slicers (top-right)

Add 3 **Slicer** visuals:
- Slicer 1: `Order Date` → set to **Year** only (dropdown style)
- Slicer 2: `Region` (dropdown style)
- Slicer 3: `Category` (dropdown style)

---

## 5. Page 2 — Product & Discount Analysis

### 5a. Top 10 Products by Sales (top-left)

- Visual: **Clustered Bar Chart**
- Y-axis: `Product Name`
- X-axis: `[Total Sales]`
- Filter: **Top N → Top 10** by `[Total Sales]`

### 5b. Discount Impact on Margin (top-right)

1. First, create a calculated column:
```dax
Discount Band = 
SWITCH(
    TRUE(),
    'Cleaned_Data'[Discount] = 0, "0% (No discount)",
    'Cleaned_Data'[Discount] <= 0.10, "1-10%",
    'Cleaned_Data'[Discount] <= 0.20, "11-20%",
    'Cleaned_Data'[Discount] <= 0.30, "21-30%",
    "30%+"
)
```
2. Visual: **Line and Clustered Column Chart**
   - X-axis: `Discount Band`
   - Column Y-axis: Count of `Row ID` (order count)
   - Line Y-axis: `[Profit Margin]`

### 5c. Sub-Category Profitability (bottom-left)

- Visual: **Treemap**
- Group: `Sub-Category`
- Values: `[Total Sales]`
- Color saturation: `[Total Profit]` (green = high, red = negative)

### 5d. Year-over-Year Sales (bottom-right)

- Visual: **Clustered Column Chart**
- X-axis: `Order Date` (Year only)
- Y-axis: `[Total Sales]`
- Data labels: **On**

---

## 6. Formatting & Theme

1. **Theme**: Go to **View → Themes → Browse for themes** or use a dark theme
   - Background: Dark navy (#1E1E2E) or charcoal (#2D2D3D)
   - Card backgrounds: Slightly lighter (#3A3A4A)
   - Font color: White
2. **Title**: Add a text box at the top: "E-Commerce Sales Performance Analysis"
3. **Font**: Use Segoe UI (Power BI default) or DIN
4. **Borders**: Round corners on cards, subtle drop shadows

## 7. Save & Export

1. **Save**: File → Save As → `PowerBI/Dashboard.pbix`
2. **Screenshots**: 
   - Navigate to Page 1 → File → Export → PNG (or use Print Screen)
   - Save to `Dashboard_Screenshots/01_Overview_Dashboard.png`
   - Navigate to Page 2 → repeat
   - Save to `Dashboard_Screenshots/02_Product_Discount_Analysis.png`

---

## Quick Reference — Expected Values

| KPI | Value |
|-----|-------|
| Total Sales | $2,297,201 |
| Total Profit | $286,397 |
| Total Orders | 5,009 |
| Profit Margin | 12.47% |
| Avg Order Value | $458.61 |
| Top Region | West ($108K profit) |
| Top Category | Technology ($145K profit) |
| Top Product | Canon imageCLASS 2200 ($61.6K) |
