library(tidyverse)
library(lubridate)
library(shiny)
library(shinyjs)
library(plotly)

# Read data
supplychain_data <- read.csv("US_Regional_Sales_Data.csv")

# View the first few rows of the dataset
head(supplychain_data)

#summary
summary(supplychain_data)

# Structure of the Dataset
str(supplychain_data)

# Data preprocessing 

#data cleaning and preproccesing

na_count <- sum(is.na(supplychain_data))

# Remove rows with missing values if necessary
supplychain_data <- na.omit(supplychain_data)


# Convert date columns to Date format if needed
supplychain_data$ProcuredDate <- as.Date(supplychain_data$ProcuredDate, format = "%d/%m/%Y")
supplychain_data$OrderDate <- as.Date(supplychain_data$OrderDate, format = "%d/%m/%Y")
supplychain_data$ShipDate <- as.Date(supplychain_data$ShipDate, format = "%d/%m/%Y")
supplychain_data$DeliveryDate <- as.Date(supplychain_data$DeliveryDate, format = "%d/%m/%Y")


# Clear Dollar Sign
supplychain_data$Unit.Cost <- as.numeric(gsub("[\\$,]", "", supplychain_data$Unit.Cost))
supplychain_data$Unit.Price <- as.numeric(gsub("[\\$,]", "", supplychain_data$Unit.Price))


#Rename Columns
supplychain_data <- supplychain_data %>%
  rename(
    ProductID = X_ProductID,
    StoreID = X_StoreID,
    CustomerID = X_CustomerID,
    SalesTeamID = X_SalesTeamID )


# Define UI, includes 2 tabs, 1 of them is the main includes 8 plots , and the other includes the series time plot
ui <- fluidPage(
  useShinyjs(),
  includeCSS("styles.css"),
  titlePanel("Global Dataset Explorer"),
  tabsetPanel(
    tabPanel("Supply Chain Analysis",
             sidebarLayout(
               sidebarPanel(
                 selectInput("category", "Select Category", choices = unique(supplychain_data$WarehouseCode)),
                 checkboxGroupInput("compare", "Choose Categories to Compare", choices = unique(supplychain_data$Sales.Channel)),
                 
                 actionButton("toggleMode", "Toggle Light/Dark Mode"),
                 checkboxGroupInput("visualizations", "Choose Visualizations to Display",
                                    choices = c("Sales Channel Plot", "Warehouse Plot", "Delivery Time Plot",
                                                "Discount Plot", "Top Products Plot", "Inventory Turnover Plot", "Cost Profit Plot","piechart"),
                                    selected = c("Sales Channel Plot", "Warehouse Plot")),
                 radioButtons("value_type", label = "Select Value Type:",
                              choices = c("Absolute", "Percentage"),
                              selected = "Absolute")
               ),
               mainPanel(
                 plotlyOutput("sales_channel_plot"),
                 plotlyOutput("warehouse_plot"),
                 plotlyOutput("delivery_time_plot"),
                 plotlyOutput("discount_plot"),
                 plotlyOutput("top_products_plot"),
                 plotlyOutput("inventory_turnover_plot"),
                 plotOutput("cost_profit_plot"),
                 plotlyOutput("pie_chart")
               )
             )
    ),
    
    #The other panel that has the time series plot
    tabPanel("Sales Visualization",
             fluidPage(
               titlePanel("Sales Visualization"),
               sidebarLayout(
                 sidebarPanel(
                   dateRangeInput("dateRange", "Select Date Range:",
                                  start = min(supplychain_data$OrderDate),
                                  end = max(supplychain_data$OrderDate),
                                  min = min(supplychain_data$OrderDate),
                                  max = max(supplychain_data$OrderDate)
                   ),
                   actionButton("update", "Update"),
                 ),
                 mainPanel(
                   plotOutput("salesPlot")
                 )
               )
             )
    )
  )
)

# First Server
server_supply_chain <- function(input, output) {
  
  # Filters for this server
  filtered_data <- reactive({
    supplychain_data %>%
      filter(
        if (!is.null(input$category)) WarehouseCode %in% input$category else TRUE,
        if (!is.null(input$compare)) Sales.Channel %in% input$compare else TRUE
        # Add conditions for other filters such as date range if applicable
      )
  })
  
  # Plot 1
  output$sales_channel_plot <- renderPlotly({
      saleschannel_summary <- filtered_data() %>%
      group_by(Sales.Channel) %>%
      summarize(Total_Sales = sum(Unit.Price * Order.Quantity))
    
    p <- ggplot(saleschannel_summary, aes(x = Sales.Channel, y = Total_Sales, fill = Sales.Channel)) +
      geom_bar(stat = "identity") +
      labs(title = "Total Sales by Sales.Channel", y = "Total_Sales") +
      theme_minimal()
    
    ggplotly(p, tooltip = c("x", "y"))  # Convert ggplot to Plotly with hover on x and y
  })
  
  # Plot 2
  output$warehouse_plot <- renderPlotly({
    warehouse_summary <- filtered_data() %>%
      group_by(WarehouseCode) %>%
      summarize(Total_Sales = sum(Unit.Price * Order.Quantity))
    
    p <- ggplot(warehouse_summary, aes(x = WarehouseCode, y = Total_Sales, fill = WarehouseCode)) +
      geom_bar(stat = "identity") +
      labs(title = "Total Sales by Warehouse", y = "Total_Sales") +
      theme_minimal()
    
    ggplotly(p, tooltip = c("x", "y"))  # Convert ggplot to Plotly with hover on x and y
  })
  
  # Plot 3
  output$delivery_time_plot <- renderPlotly({
    if ("Delivery Time Plot" %in% input$visualizations) {
      filtered_data <- supplychain_data %>%
        filter(
          if (!is.null(input$category)) WarehouseCode %in% input$category else TRUE,
          if (!is.null(input$compare)) Sales.Channel %in% input$compare else TRUE
          # Add conditions for other filters such as date range if applicable
        )
      
      filtered_data$DeliveryTime <- as.numeric(difftime(filtered_data$DeliveryDate, filtered_data$OrderDate, units = "days"))
      
      delivery_time_summary <- filtered_data %>%
        group_by(Sales.Channel) %>%
        summarize(AvgDeliveryTime = mean(DeliveryTime, na.rm = TRUE))
      
      p <- ggplot(delivery_time_summary, aes(x = Sales.Channel, y = AvgDeliveryTime, fill = Sales.Channel)) +
        geom_bar(stat = "identity") +
        labs(title = "Average Delivery Time by Sales.Channel", y = "Average Delivery Time (Days)") +
        theme_minimal()
      
      ggplotly(p, tooltip = c("x", "y"))  # Convert ggplot to Plotly with hover on x and y
    }
  })
  
  # Plot 4
  output$discount_plot <- renderPlotly({
    if ("Discount Plot" %in% input$visualizations) {
      # Change variable name to avoid conflicts
      filtered_discount_data <- supplychain_data %>%
        filter(
          if (!is.null(input$category)) WarehouseCode %in% input$category else TRUE,
          if (!is.null(input$compare)) Sales.Channel %in% input$compare else TRUE
          # Add conditions for other filters such as date range if applicable
        )
      
      p <- ggplot(filtered_discount_data, aes(x = Discount.Applied, fill = Sales.Channel)) +
        geom_bar() +
        labs(title = "Discounts Applied", x = "Discount Applied", y = "Frequency")
      
      ggplotly(p, tooltip = c("x", "y"))  # Convert ggplot to Plotly with hover on x and y
    }
  })
  
  # Plot 5
  output$top_products_plot <- renderPlotly({
    if ("Top Products Plot" %in% input$visualizations) {
      filtered_top_products_data <- supplychain_data %>%
        filter(
          if (!is.null(input$category)) ProductID %in% input$category else TRUE,
          if (!is.null(input$compare)) Sales.Channel %in% input$compare else TRUE
          # Add conditions for other filters such as date range if applicable
        )
      
      # Calculate Sales for each Product
      product_summary <- supplychain_data %>%
        group_by(ProductID) %>%
        summarize(Total_Sales = sum(Unit.Price * Order.Quantity))
      
      # Plot total sales by ProductID (top 10)
      top_products <- head(product_summary[order(product_summary$Total_Sales, decreasing = TRUE), ], 10)
      p <- ggplot(top_products, aes(x = ProductID, y = Total_Sales, fill = ProductID)) +
        geom_bar(stat = "identity") +
        labs(title = "Top 10 Products by Sales", y = "Total_Sales") +
        theme_minimal()
      
      ggplotly(p, tooltip = c("x", "y"))  # Convert ggplot to Plotly with hover on x and y
    }
  })
  
  # Plot 6
  output$inventory_turnover_plot <- renderPlotly({
    if ("Inventory Turnover Plot" %in% input$visualizations) {
      filtered_data <- supplychain_data %>%
        filter(
          if (!is.null(input$category)) WarehouseCode %in% input$category else TRUE,
          if (!is.null(input$compare)) Sales.Channel %in% input$compare else TRUE
          # Add conditions for other filters such as date range if applicable
        )
      
      inventory_turnover <- filtered_data %>%
        mutate(DeliveryDate = as.Date(DeliveryDate),
               ProcuredDate = as.Date(ProcuredDate)) %>%
        group_by(ProductID) %>%
        summarise(AvgInventoryTurnover = mean(Order.Quantity / as.numeric((DeliveryDate - ProcuredDate) / 30), na.rm = TRUE))
      
      slow_moving_products <- inventory_turnover %>%
        filter(AvgInventoryTurnover < 1)  # Adjust threshold as needed
      
      if (nrow(slow_moving_products) > 0) {
        p <- ggplot(slow_moving_products, aes(x = ProductID, y = AvgInventoryTurnover)) +
          geom_bar(stat = "identity") +
          labs(title = "Slow-Moving Products")
        
        ggplotly(p, tooltip = c("x", "y"))  # Convert ggplot to Plotly with hover on x and y
      } else {
        p <- ggplot() + geom_blank() + labs(title = "No Slow-Moving Products")
        ggplotly(p)  # Convert ggplot to Plotly
      }
    }
  })
  
  # Plot 7
  output$cost_profit_plot <- renderPlot({
    if ("Cost Profit Plot" %in% input$visualizations){
      filtered_data <- supplychain_data %>%
        filter(
          if (!is.null(input$category)) WarehouseCode %in% input$category else TRUE,
          if (!is.null(input$compare)) Sales.Channel %in% input$compare else TRUE
          # Add conditions for other filters such as date range if applicable
        )
      
      filtered_data$TotalCost <- filtered_data$Unit.Cost * filtered_data$Order.Quantity
      filtered_data$TotalProfit <- (filtered_data$Unit.Price - filtered_data$Unit.Cost) * filtered_data$Order.Quantity
      
      total_cost <- sum(filtered_data$TotalCost)
      total_profit <- sum(filtered_data$TotalProfit)
      
      hist(filtered_data$TotalCost, main = "Total Cost Distribution", xlab = "Total Cost")
      hist(filtered_data$TotalProfit, main = "Total Profit Distribution", xlab = "Total Profit")
      cat("Total Cost:", total_cost, "\n")
      cat("Total Profit:", total_profit, "\n")
    }
  })
  
  # Plot 8
  output$pie_chart <- renderPlotly({
    if ("piechart" %in% input$visualizations) {
      data <- table(filtered_data()$Sales.Channel)  # Change to your desired column
      
      if (input$value_type == "Absolute") {
        labels <- names(data)
        values <- as.numeric(data)
        text <- paste(labels, "<br>", "Count: ", values)
      } else {
        data_percentage <- prop.table(data) * 100
        labels <- names(data_percentage)
        values <- as.numeric(data_percentage)
        text <- paste(labels, "<br>", "Percentage: ", round(values, 2), "%")
      }
      
      p <- plot_ly(labels = labels, values = values, type = 'pie', text = text,
                   hoverinfo = "text") %>%
        layout(title = "Sales Channels Distribution")
      
      p  # Return Plotly object
    }
  })
  
  shinyjs::runjs('localStorage.setItem("mode", "light");')
  
  observeEvent(input$toggleMode, {
    shinyjs::runjs('
      var mode = localStorage.getItem("mode");
      if (mode === "light") {
        document.body.classList.add("dark-mode");
        localStorage.setItem("mode", "dark");
      } else {
        document.body.classList.remove("dark-mode");
        localStorage.setItem("mode", "light");
      }
    ')
  })
}

# Second Server
server_sales_visualization <- function(input, output) {
  filtered_data <- eventReactive(input$update, {
    start_date <- input$dateRange[1]
    end_date <- input$dateRange[2]
    
    supplychain_data %>%
      filter(OrderDate >= start_date & OrderDate <= end_date) %>%
      group_by(OrderDate) %>%
      summarise(total_quantity = sum(Order.Quantity))
  })
  
  output$salesPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = OrderDate, y = total_quantity)) +
      geom_line() +
      labs(title = "Sales Quantity Over Time",
           x = "Date",
           y = "Total Quantity") +
      theme_minimal()
  })
}

# Run the server
shinyApp(ui = ui, server = server_supply_chain) # Run for Supply Chain (Tab 1)
shinyApp(ui = ui, server = server_sales_visualization)  # Run for sales visualization (Tab 2)
