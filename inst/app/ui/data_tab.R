data_tab <- tabItem(
  tabName = "data_tab",
  h2("Data"),
  fileInput("tbl_file", NULL, width = "100%", placeholder = "Load Table"),
  fluidRow(
    column(2, downloadButton("dl_tbl", "Download")),
    column(10, radioButtons("tbl_yml_switch", NULL, c("table", "yaml"), "table", inline = TRUE))
    
  ),
  fluidRow(
    column(4, actionButton("add_col", NULL, icon("plus")),
           actionButton("delete_col", NULL, icon("minus")),
           actionButton("rename_col", "Rename"),
           actionButton("reorder_col", "Reorder")
    ),
    column(4, selectizeInput("col_name", NULL, c(), multiple = TRUE,
                             options = list(create = TRUE), width = "100%")),
    column(4, textInput("col_val", NULL, placeholder = "Column value/new name", width = "100%"))
    
  ),
  
  DTOutput("tbl"),
  verbatimTextOutput("yml")
)