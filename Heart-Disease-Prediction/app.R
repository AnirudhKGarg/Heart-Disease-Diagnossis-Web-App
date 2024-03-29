#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(dplyr)
library(tidyverse)
library(rsconnect)

# Import the csv and check the structure
data <- read.csv("Heart_Disease_Prediction.csv")

# Modify the data and clean the fields for ease of reading and interpretation
df <- data %>% 
    mutate(Sex = ifelse(Sex == 1, "Male",  "Female")) %>% 
    mutate(Exercise.angina = ifelse(Exercise.angina == 1, "Yes",  "No")) %>% 
    mutate(FBS.over.120 = ifelse(FBS.over.120 == 1, "Yes",  "No")) %>% 
    mutate(EKG.results = recode(EKG.results, "0" = "Normal", "1" = "Abnormal", "2" = "Severe")) %>% 
    mutate(Chest.pain.type = recode(Chest.pain.type, "1" = "Typical Angina", "2" = "Abnormal Angina", "3" = "Non-Aginal Pain", "4" = "Asymptomatic")) %>% 
    mutate(Slope.of.ST = recode(Slope.of.ST, "1" = "Up", "2" = "Flat", "3" = "Down")) %>% 
    mutate(Thallium = recode(Thallium, "3" = "Normal", "6" = "Fixed", "7" = "Reversed")) %>% 
    mutate(Heart.Disease = ifelse(Heart.Disease == "Presence", 1, 0))

# Define UI for application
ui <- fluidPage(
    # Application title
    titlePanel("Heart Disease Predictor"),
    
    # Sidebar with input parameters and interpretation text
    sidebarLayout(
        sidebarPanel(
            numericInput("Age", "Age:", value = 50, min = 0, max = 120),
            numericInput("Cholesterol", "Cholesterol:", value = 200, min = 0, max = 500),
            numericInput("Max.HR", "Max Heart Rate:", value = 150, min = 0, max = 300),
            numericInput("BP", "Blood Pressure:", value = 120, min = 0, max = 300),
            numericInput("ST.depression", "Stent Depression:", value = 0, min = 0, max = 10)
        ),
        
        # Show the model prediction and donut chart
        mainPanel(
            verbatimTextOutput("prediction"),
            plotlyOutput("importance_chart"),
            h3("Model Interpretation"),
            helpText("This model predicts the risk of heart disease based on several factors including age, cholesterol levels, maximum heart rate, blood pressure, and stent depression. Predictions are made at the 95% confidence interval and does not constitute medical advice. Ask your doctor if you have concerns of developing heart disease."),
            h3("Study Limitations"),
            helpText("It's important to note that many studies on heart disease historically focused more on men than women. As such, this model does not include biological sex as a variable. While the UCI dataset used to train the mode is more representative of heart disease patients, medical bias may affect the accuracy of predictions for women and highlights the need for further inclusive research.")
        )
    )
)

# Define server logic
server <- function(input, output) {
    
    # Define the logistic regression model
    model <- glm(Heart.Disease ~ Age + Cholesterol + Max.HR + BP + ST.depression + Sex, data = df, family = binomial())
    
    # Predict the probability of heart disease
    predict_disease <- function(Age, Cholesterol, Max.HR, BP, ST.depression) {
        new_data <- data.frame(Age = Age, Cholesterol = Cholesterol, Max.HR = Max.HR, BP = BP, ST.depression = ST.depression, Sex = "Male")
        prob <- predict(model, newdata = new_data, type = "response")
        return(prob)
    }
    
    # Calculate the importance of each variable
    variable_importance <- function(model) {
        var_imp <- data.frame(exp(coef(model)))
        var_imp$Variable <- row.names(var_imp)
        var_imp$Percent <- round(var_imp$exp.coef / sum(var_imp$exp.coef) * 100, 1)
        var_imp$Variable[var_imp$Variable == "(Intercept)"] <- "Baseline Risk"
        var_imp <- var_imp[-7,] # Remove "Sex" variable from chart
        return(var_imp)
    }
    
    # Render the model prediction
    output$prediction <- renderPrint({
        prob <- predict_disease(input$Age, input$Cholesterol, input$Max.HR, input$BP, input$ST.depression)
        paste0("Risk of Developing Heart Disease: ", round(prob * 100, 2), "%")
    })
    
    # Render the donut chart for variable importance
    output$importance_chart <- renderPlotly({
        imp <- variable_importance(model)
        fig <- plot_ly(labels = imp$Variable, values = imp$Percent, type = "pie", textposition = "inside", textinfo = "percent", marker = list(colors = c("red", "orange", "yellow", "green", "blue")), hole = 0.55)
        fig <- fig %>% layout(title = "Importance of Risk Factors", legend = list(orientation = "h", y = -0.1), annotations = list(text = "Variables", x = 0.5, y = 0.5, showarrow = FALSE))
        fig
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

