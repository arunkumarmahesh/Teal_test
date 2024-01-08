library(htmltools)
library(rlang)#
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(DT)
library(admiral)
library(checkmate)
library(formatters)
library(rtables)
library(tern)#
library(teal.widgets) 
library(teal.logger) 
library(teal.code) 
library(teal.data)
library(teal.slice)
library(teal.transform)
library(teal)
library(teal.modules.clinical)#
library(dplyr)
library(nestcolor)
library(ggplot2)
library(tibble)

Year_list <- system(paste0("ls ~/Desktop/DEA_APP/test"), intern = T)
  
data_mod <- teal_data_module(
  ui = function(id) {
    ns = NS(id) 
    list(
  selectizeInput(
    inputId = ns("Year"),
    label   = 'Select Year',
    choices = Year_list),
  
  selectizeInput(
    inputId = ns("Month"),
    label   = 'Select Month',
    choices = NULL),
  
  selectizeInput(
    inputId = ns("Fruits"),
    label   = 'Select Fruits',
    choices = NULL),
    actionButton(ns("submit"), "Submit"))
  },
  
  server = function(id) {
    moduleServer(id, function(input, output, session) {
      
      Month <- reactive({
        req(input$Year)
      })
      observeEvent(Month(),{
        updateSelectInput(inputId = "Month",
                          choices = list.files(path = file.path("~/Desktop/DEA_APP/test",
                                                                input$Year)))
      })
      
        Fruits <- reactive({
          req(input$Month)
        })
        observeEvent(Fruits(),{
          updateSelectInput(inputId = "Fruits",
                            choices = list.files(path = file.path("~/Desktop/DEA_APP/test",
                                                                  input$Year, input$Month)))
        })
        
        dat1 <- reactive({
          req(input$Fruits,input$Month, input$Year)
          readxl::read_excel(input$Year, input$Month, input$Fruits)
        })
        
        
        eventReactive(input$submit, {
          dat1 <- within(
            teal_data(),{
              d1 <- dat1()
              
            })
          datanames(dat1) <- "d1"
          dat1
        })
    })
  }
)


app <- init(
  data = data_mod,
  module = example_module()
)

shinyApp(app$ui, app$server)
