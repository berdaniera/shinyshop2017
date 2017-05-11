library(leaflet)
# R ENVIRONMENT
library(shiny)

sites <- list(lng = c(175,-79), lat = c(-36,36), id=c("site1","site2"))

# UI, this is a function call, so contents are elements = need commas between
ui <- fluidPage(
  leafletOutput("mymap"),
  textOutput("site")
)


# SERVER, this is a function definition, so contents are objects
server <- function(input, output){
  output$mymap <- renderLeaflet({
    m <- leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      addMarkers(lng=sites$lng, lat=sites$lat, layerId=sites$id, popup="The birthplace of R")
    m  # Print the map
  })
  
  output$site <- renderText("Nothing clicked")
  
  observeEvent(input$mymap_marker_click, {
    clicked_site <- input$mymap_marker_click$id
    output$site <- renderText(clicked_site)
  })  
  
}

shinyApp(ui = ui, server = server)