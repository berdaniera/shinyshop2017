library(shiny)

# UI, this is a function call, so contents are elements = need commas between
ui <- fluidPage(
  h1("My app"),
  sidebarLayout(
    sidebarPanel(
      h2("Add data"),
      selectInput("site", "Choose a site:", choices=c("site1","site2")),
      numericInput("nwidget","How many widgets did you see?", 0, min=0),
      numericInput("weather","What was the temperature?", 0),
      actionButton("add","Add this data")
    ),
    mainPanel(
      h2("View data"),
      tableOutput("mytable")
    )
  )
)


# FIRST SERVER, this is a function definition, so contents are objects
server <- function(input, output){
  # render table is a reactive function
  output$mytable <- renderTable({
    current_time <- as.character(Sys.time())
    data.frame(addtime = current_time, 
               site = input$site, 
               nwidgets = input$nwidget, 
               weather = input$weather)
  })
}

shinyApp(ui = ui, server = server)


# SECOND SERVER
server <- function(input, output){
  observeEvent(input$add, {
    current_time <- as.character(Sys.time())
    data <- data.frame(addtime = current_time, 
               site = input$site, 
               weather = input$weather, 
               nwidgets = input$nwidget)
    # render table is a reactive function
    output$mytable <- renderTable({ data })
  })
}

shinyApp(ui = ui, server = server)


# THIRD SERVER
server <- function(input, output){
  data <- reactiveValues()
  current_time <- as.character(Sys.time())
  data$x <- data.frame(addtime = current_time, 
               site = 0, 
               weather = 0, 
               nwidgets = 0)

  observeEvent(input$add, {
    data$x <- data.frame(addtime = current_time, 
                         site = input$site, 
                         weather = input$weather, 
                         nwidgets = input$nwidget)

    output$mytable <- renderTable({ data$x }) # this is reactive too...
  })
}

shinyApp(ui = ui, server = server)

# all kinds of reaction, they work like functions
# - observe({ reaction }) is constantly evaluating, can do stuff like if(!is.null(x)) dostuff
# - xx <- reactive({ data.frame(a=x,b=y) }) is a reactive object
# - xx <- reactiveValues(a=x, b=y) is a reactive list
# - xx <- eventReactive(event, {reaction}) # assign a reactive object with an event
# - observeEvent(event, {reaction}) # do some action on an event
