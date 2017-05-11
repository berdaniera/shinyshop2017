# R ENVIRONMENT
library(shiny)

# UI, this is a function call, so contents are elements = need commas between
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      # site selection
      selectInput("site","Choose a site", choices=c("site1","site2")),
      # input1
      numericInput("nwidget","How many widgets did you see?", 0, min=0),
      # input2
      numericInput("weather","What was the temperature?", 0),
      #action button
      actionButton("add","Add this data")
    ),
    mainPanel(
      h2("View the data"),
      tableOutput("mytable")
    )
  )
)

# SERVER, this is a function definition, so contents are objects
server <- function(input, output){
  mydata <- reactiveValues()
  current_time <- as.character(Sys.time())
  mydata$x <- data.frame(addtime = current_time,
                       site = 0,
                       weather = 0,
                       nwidgets = 0)
  
  observeEvent(input$add, {
    current_time <- as.character(Sys.time())
    mydata$x <- data.frame(addtime = current_time,
                         site = input$site,
                         weather = input$weather,
                         nwidgets = input$nwidget)
    mydata$x
  })
  
  output$mytable <- renderTable({ mydata$x })
  
  
}

shinyApp(ui = ui, server = server)