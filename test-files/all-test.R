library(googlesheets)
library(leaflet)
library(shiny)
library(dplyr)

gs_auth(token = "shiny_app_token.rds")

key <- "1MuXoFDARgFGWWRclgWzcBGSRX0qeovVQd48bEVDyplE"
ss <- gs_key(key)

save_gdata <- function(data) gs_add_row(ss, input = data)
load_gdata <- function() gs_read(ss)

sites <- list(lng=c(175,-79), lat=c(-36,36), id=c("site1","site2"))

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
      tableOutput("mytable"),
      plotOutput("myplot"),
      p("Sites"),
      leafletOutput("mymap")
    )
  )
)

server <- function(input, output){

  # load the sheet
  data <- load_gdata()
  # render the table
  output$mytable <- renderTable({ data })
  output$myplot <- renderPlot(plot(data$weather, data$nwidgets, col=factor(data$site), pch=19))
  
  observeEvent(input$add, {
    # get the data
    current_time <- as.character(Sys.time())
    data <- data.frame(addtime = current_time, 
                       site = input$site, 
                       weather = input$weather, 
                       nwidgets = input$nwidget)
    print(data)
    # add the data to the sheet
    save_gdata(data)
    # load the sheet
    data <- load_gdata()
    # render the table
    output$mytable <- renderTable({ data })
    # render the plot
    output$myplot <- renderPlot(plot(data$weather, data$nwidgets, col=factor(data$site), pch=19))
  })
  
  output$mymap <- renderLeaflet({
    leaflet() %>% addTiles() %>% addMarkers(lng=sites$lng, lat=sites$lat, popup=sites$id, layerId=sites$id)
  })
  
  # # Map reactive - not working
  # observeEvent(input$mymap_marker_click, {
  #   print("aaron")
  #   point <- input$mymap_marker_click
  #   output$lat <- renderText(point$lat)
  # })
}

shinyApp(ui = ui, server = server)
