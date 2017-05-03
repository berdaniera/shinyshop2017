
# library(leaflet)
# m <- leaflet() %>%
#   addTiles() %>%  # Add default OpenStreetMap map tiles
#   addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
# m  # Print the map


library(leaflet)
library(shiny)

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
      leafletOutput("mymap"),
      tableOutput("mytable")
    )
  )
)

# SERVER, this is a function definition, so contents are objects
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
  })
  
  output$mytable <- renderTable({ data$x })
  
  output$mymap <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      addMarkers(lng=sites$lng, lat=sites$lat, popup=sites$id, layerId=sites$id)
  })
}

shinyApp(ui = ui, server = server)
