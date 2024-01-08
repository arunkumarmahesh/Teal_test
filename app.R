library(teal)
library(readxl)

root_path <- "test"

data_mod <- teal_data_module(
  ui = function(id) {
    ns <- NS(id)
    list(
      selectizeInput(
        inputId = ns("Year"),
        label   = "Select Year",
        choices = list.files(root_path)
      ),
      selectizeInput(
        inputId = ns("Month"),
        label   = "Select Month",
        choices = NULL
      ),
      selectizeInput(
        inputId = ns("Fruits"),
        label   = "Select Fruits",
        choices = NULL
      ),
      actionButton(ns("submit"), "Submit")
    )
  },
  server = function(id) {
    moduleServer(id, function(input, output, session) {
      observeEvent(input$Year, {
        updateSelectInput(
          inputId = "Month",
          choices = list.files(path = file.path(
            root_path,
            input$Year
          ))
        )
      })

      observeEvent(input$Month, {
        updateSelectInput(
          inputId = "Fruits",
          choices = list.files(path = file.path(
            root_path,
            input$Year, input$Month
          ))
        )
      })

      dat1 <- reactive({
        req(input$Fruits, input$Month, input$Year)
        readxl::read_excel(file.path(root_path, input$Year, input$Month, input$Fruits))
      })


      eventReactive(input$submit, {
        dat1 <- within(
          teal_data(),
          {
            d1 <- selected_data
          },
          selected_data = dat1()
        )
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
