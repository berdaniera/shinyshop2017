library(googlesheets)
library(leaflet)
library(shiny)

gs_auth(token = "shiny_app_token.rds")

key <- "1MuXoFDARgFGWWRclgWzcBGSRX0qeovVQd48bEVDyplE"
ss <- gs_key(key)

save_gdata <- function(data) gs_add_row(ss, input = data)
load_gdata <- function(site=NULL){
  dd <- gs_read(ss)
  if(!is.null(site)){
    dd <- dd[which(dd$site==site),]
  }
  return(dd)
}

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
      downloadButton("downloadData","Download this as a .csv"),
      plotOutput("myplot"),
      p("Sites"),
      leafletOutput("mymap")
    )
  )
)

server <- function(input, output){
  # load the sheet
  data <- reactiveValues()
  data$x <- load_gdata()

  observeEvent(input$add, {
    # get the data
    current_time <- as.character(Sys.time())
    add_data <- data.frame(addtime = current_time, 
                           site = input$site, 
                           weather = input$weather, 
                           nwidgets = input$nwidget)
    print(add_data)
    # add the data to the sheet
    save_gdata(add_data)
    # load the sheet
    data$x <- load_gdata()
  })
  
  # render outputs
  output$mytable <- renderTable({ data$x })
  output$myplot <- renderPlot({
    dd <- data$x
    plot(dd$weather, dd$nwidgets, col=factor(dd$site), pch=19)
  })
  output$mymap <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      addMarkers(lng=sites$lng, lat=sites$lat, popup=sites$id, layerId=sites$id)
  })
  
  # map events
  observeEvent(input$mymap_marker_click, {
    clicked_site <- input$mymap_marker_click$id
    data$x <- load_gdata(clicked_site)
  })
  observeEvent(input$mymap_click, {
    data$x <- load_gdata()
  })

  # download handler
  output$downloadData <- downloadHandler(
    filename=function(){ paste0("mydata",Sys.Date(),".csv") },
    content = function(con){
      write.csv(data$x, con, row.names=FALSE)
    }
  )
}

shinyApp(ui = ui, server = server)
