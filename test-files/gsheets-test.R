# google sheets test
library(googlesheets)

shiny_token <- gs_auth() # authenticate
saveRDS(shiny_token, "shiny_app_token.rds")
initial_sheet <- data.frame(addtime=0, site=0, weather=0, nwidgets=0)
# need to set up with our columns...
ss <- gs_new("my-shiny-data", input=initial_sheet)
sheetkey <- ss$sheet_key # like: "10kYZGTfXquVUwvBXH-8M-p01csXN6MNuuTzxnDdy3Pk"
ss <- googlesheets::gs_key(sheetkey)

save_gdata <- function(data){
  gs_add_row(ss, input = data)
}
load_gdata <- function(){
  # add site parameter
  dd <- gs_read(ss)
  return(dd)
}
