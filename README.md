# Supply Chain Analysis and Sales Visualization with Shiny

*This project was developed as part of the Information Visualization course at the Faculty of Computer and Information Sciences (FCIS), Ain Shams University (ASU).*

<b>

This R code serves as a comprehensive toolset for conducting supply chain analysis and sales visualization within the context of a Shiny web application. Leveraging key libraries such as `tidyverse`, `lubridate`, `shiny`, `shinyjs`, and `plotly`, it presents an interactive platform to explore and analyze a supply chain dataset in a user-friendly manner.

## Dataset Description:

The dataset provided for supply chain analysis is a detailed collection of various columns capturing crucial information related to the company's order and distribution processes. Each column holds significant attributes that contribute to understanding the intricacies of the supply chain, including:

- **OrderNumber:** Identifies each unique order made within the company.
- **Sales Channel:** Indicates the specific channel (e.g., online, in-store) through which sales transactions occurred.
- **WarehouseCode:** Represents the code corresponding to the warehouse responsible for dispatching the product.
- **ProcuredDate:** Records the date when products were procured or obtained for the supply chain.
- **CurrencyCode:** Specifies the currency used for the transactions.
- **OrderDate, ShipDate, DeliveryDate:** Chronological records of the order timeline—placement, shipment, and delivery dates.
- **SalesTeamID, CustomerID, StoreID, ProductID:** Unique identifiers for sales team, customers, stores, and products, respectively.
- **Order Quantity:** Quantity of products ordered in each transaction.
- **Discount Applied:** Amount of discount applied to the order.
- **Unit Cost:** Cost per unit of the product.
- **Unit Price:** Price per unit of the product.

## Code Overview:

### 1. Data Loading and Preprocessing

#### Libraries:
The code begins by loading necessary R libraries (`tidyverse`, `lubridate`, `shiny`, `shinyjs`, `plotly`).

#### Data Reading:
Reads data from a CSV file named "US_Regional_Sales_Data.csv" into the `supplychain_data` dataframe and displays its initial rows, summary, and structure.

#### Data Summary and Statistics:
- **Length:** Indicates the number of entries or observations in each column (7991 observations for each column).
- **Class:** Displays the data type or class of the values within each column (all columns are detected as character type).
- **Mode:** Represents the most frequent value mode within each column.
- **Statistical Measures:** For numerical columns (`X_SalesTeamID`, `X_CustomerID`, `X_StoreID`, `X_ProductID`, `Order.Quantity`, `Discount.Applied`), the summary provides statistical measures:
  - Min.: Minimum value observed in the column.
  - 1st Qu.: First quartile or 25th percentile.
  - Median: Median or 50th percentile.
  - Mean: Mean or average value.
  - 3rd Qu.: Third quartile or 75th percentile.
  - Max.: Maximum value observed.
- For non-numerical columns (`OrderNumber`, `Sales.Channel`, `WarehouseCode`, `ProcuredDate`, `OrderDate`, `ShipDate`, `DeliveryDate`, `CurrencyCode`), the summary provides the length, class, and mode as these columns contain text or categorical data.

#### Data Cleaning:
- Checks for missing values (`na_count`) and removes rows with missing data (`na.omit`).
- Converts date columns from character format to the Date format (`as.Date`) using a specific date format (format = "%d/%m/%Y").
- Clears dollar signs from cost-related columns and converts them to numeric format using `gsub` and `as.numeric`.

#### Column Renaming:
Renames columns for improved clarity and consistency within the dataset.

### 2. User Interface (UI) Development

#### Tabbed Interface:
Defines a Shiny app UI with two distinct tabs—'Supply Chain Analysis' and 'Sales Visualization'.

#### Input Elements:
Includes various interactive input elements like dropdown menus (`selectInput`), checkboxes (`checkboxGroupInput`), and date range selectors (`dateRangeInput`) for filtering the dataset.

#### Visualization Options:
Offers a selection of visualizations using `plotlyOutput` and `plotOutput` for diverse insights.

### 3. Supply Chain Analysis Server Functions

#### Server Functions:
Defines server functions (`server_supply_chain`) to render dynamic plotly visualizations:
- Total Sales by Sales Channel
- Total Sales by Warehouse
- Average Delivery Time by Sales Channel
- Discounts Applied
- Top 10 Products by Sales
- Inventory Turnover Analysis
- Total Cost and Total Profit Distribution
- Sales Channels Distribution as a pie chart

#### Dark Mode Functionality:
Implements a feature allowing users to switch between light and dark modes for improved user experience.

### 4. Sales Visualization Server Function

#### Server Function:
Defines a server function (`server_sales_visualization`) to display a time series plot showcasing the variation of sales quantity over time.

### 5. Execution

#### Application Execution:
Runs `shinyApp` separately for both supply chain analysis and sales visualization, ensuring distinct functionalities.
