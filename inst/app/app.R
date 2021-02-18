## libraries ----
suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinydashboard)
    library(DT)
    library(yaml)
    library(rio)
})

## functions ----

tbl2yaml <- function(tbl) {
    utils::type.convert(tbl, as.is = TRUE) %>%
        yaml::as.yaml(column.major = FALSE) %>%
        gsub(": .na\n", ": \n", ., fixed = TRUE) %>%
        gsub("'(#[^\n]*)'\n", "\\1\n", .)
}


# source("R/func.R") # put long functions in external files

# display debugging messages in R if local,
# or in the console log if remote
debug_msg <- function(...) {
    is_local <- Sys.getenv('SHINY_PORT') == ""
    txt <- paste(...)
    if (is_local) {
        message(txt)
    } else {
        shinyjs::logjs(txt)
    }
}

## tabs ----

# you can put complex tabs in separate files and source them
#source("ui/main_tab.R")
#source("ui/info_tab.R")

main_tab <- tabItem(
    tabName = "main_tab",
    h2("Main")
)

yaml_tab <- tabItem(
    tabName = "yaml_tab",
    h2("YAML"),
    fileInput("tbl_file", "Load Table", width = "100%"),
    fluidRow(
        column(4, actionButton("add_col", NULL, icon("plus")),
               actionButton("delete_col", NULL, icon("minus")),
               actionButton("rename_col", "Rename")
        ),
        column(4, selectizeInput("col_name", NULL, c(), multiple = TRUE,
                                 options = list(create = TRUE))),
        column(4, textInput("col_val", NULL, placeholder = "Column value/new name"))

    ),
    downloadButton("dl_yaml", "Download YAML"),
    verbatimTextOutput("yaml_text")
)


# if the header and/or sidebar get too complex,
# put them in external files and uncomment below
# source("ui/header.R") # defines the `header`
# source("ui/sidebar.R") # defines the `sidebar`


## UI ----
ui <- dashboardPage(
    skin = "red",
    # header, # if sourced above
    # sidebar, # if sourced above
    dashboardHeader(title = "MarkR"),
    dashboardSidebar(
        # https://fontawesome.com/icons?d=gallery&m=free
        sidebarMenu(
            id = "tabs",
            #menuItem("Main", tabName = "main_tab",
            #         icon = icon("home")),
            menuItem("YAML", tabName = "yaml_tab",
                     icon = icon("table"))
        )
    ),
    dashboardBody(
        shinyjs::useShinyjs(),
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css") # links to www/custom.css
        ),
        tabItems(
            #main_tab,
            yaml_tab
        )
    )
)


## server ----
server <- function(input, output, session) {
    tbl <- reactiveVal(data.frame())
    filename <- reactiveVal("file")

    observeEvent(input$tbl_file, {
        debug_msg("tbl_file")

        path <- input$tbl_file$datapath
        filename(input$tbl_file$name)
        debug_msg(path)

        x <- tryCatch({
            rio::import(path)
        }, error = function(e) {
            shinyjs::alert(e$message)
            return(data.frame())
        })

        updateSelectizeInput(session, "col_name", choices = names(x))

        tbl(x)
    }, ignoreNULL = TRUE)

    output$yaml_text <- renderText({
        tbl2yaml(tbl())
    })

    output$dl_yaml <- downloadHandler(
        filename = function() {
            debug_msg("dl_yaml")
            paste0(filename(), ".yml")
        },
        content = function(file) {
            txt <- tbl2yaml(tbl())
            write(txt, file)
        }
    )

    # add_col ----
    observeEvent(input$add_col, {
        debug_msg("add_col: ", input$col_name)
        if (any(trimws(input$col_name) == "")) return()
        t <- tbl()
        for (n in input$col_name) {
            t[n] <- input$col_val
        }
        tbl(t)
        updateTextInput(session, "col_val", value = "")
        updateSelectizeInput(session, "col_name", choices = names(t))
    })

    # delete_col ----
    observeEvent(input$delete_col, {
        debug_msg("delete_col: ", input$col_name)
        t <- tbl()
        for (n in input$col_name) {
            t[n] <- NULL
        }
        tbl(t)
        updateSelectizeInput(session, "col_name", choices = names(t))
    })

    # rename_col ----
    observeEvent(input$rename_col, {
        debug_msg("rename_col: ", input$col_name[[1]])
        oldname <- trimws(input$col_name[[1]])
        newname <- trimws(input$col_val)
        if (newname == "") return()
        if (oldname == "") return()
        t <- dplyr::rename(tbl(), !!newname := oldname)
        tbl(t)
        updateTextInput(session, "col_val", value = "")
        updateSelectizeInput(session, "col_name", choices = names(t))
    })

}

shinyApp(ui, server)
