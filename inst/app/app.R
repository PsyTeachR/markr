## libraries ----
suppressPackageStartupMessages({
    library(shiny)
    library(shinyjs)
    library(shinydashboard)
    library(DT)
    library(dplyr)
    library(yaml)
    library(rio)
    library(ukbabynames)
    library(stringr)
    library(markr)
})

## functions ----
source("R/func.R")

## tabs ----

# you can put complex tabs in separate files and source them
source("ui/data_tab.R")
source("ui/temp_tab.R")

## UI ----
ui <- dashboardPage(
    skin = "red",
    dashboardHeader(title = "MarkR"),
    dashboardSidebar(
        # https://fontawesome.com/icons?d=gallery&m=free
        sidebarMenu(
            id = "tabs",
            menuItem("Data", tabName = "data_tab",
                     icon = icon("table")),
            menuItem("Template", tabName = "temp_tab",
                     icon = icon("file-alt"))
        ),
        actionButton("reset", "Reset")
    ),
    dashboardBody(
        shinyjs::useShinyjs(),
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css") 
        ),
        tabItems(
            data_tab,
            temp_tab
        )
    )
)


## server ----
server <- function(input, output, session) {
    tbl <- reactiveVal(demo_tbl())
    filename <- reactiveVal("demo")
    
    observeEvent(input$reset, { # reset ----
        debug_msg("reset")
        
        filename("demo")
        tbl(demo_tbl())
        
        updateTextAreaInput(session, "template_text", value = template_text)
        output$test_output <- renderUI("")
    })
    
    observeEvent(input$tbl_yml_switch, { # tbl_yml_switch ----
        debug_msg("tbl_yml_switch:", input$tbl_yml_switch)
        
        if (input$tbl_yml_switch == "table") {
            show("tbl")
            hide("yml")
        } else {
            show("yml");
            hide("tbl")
        }
    })
    
    # update selectize with col names ----
    observe({
        debug_msg("update col_name/group_by")
        updateSelectizeInput(session, "col_name", choices = names(tbl()))
        updateSelectizeInput(session, "group_by", choices = names(tbl()))
    })

    observeEvent(input$tbl_file, { # tbl_file ----
        debug_msg("tbl_file:", input$tbl_file$name)

        path <- input$tbl_file$datapath
        fname <- tools::file_path_sans_ext(input$tbl_file$name)
        ext <- tools::file_ext(input$tbl_file$name)
        filename(fname)

        x <- tryCatch({
            if (ext == "yml") {
                markr::read_marks(yaml = path)
            } else {
                rio::import(path)
            }
        }, error = function(e) {
            shinyjs::alert(e$message)
            return(data.frame())
        })

        tbl(x)
    }, ignoreNULL = TRUE)

    output$yml <- renderText({ # yml ----
        markr::tbl2yaml(tbl(), open = FALSE)
    })
    
    output$tbl <- renderDT({ # tbl ----
        tbl()
    }, rownames = FALSE,)

    output$dl_tbl <- downloadHandler( #dl_tbl ----
        filename = function() {
            debug_msg("dl_tbl")
            if (input$tbl_yml_switch == "yaml") {
              paste0(filename(), ".yml")
            } else {
              paste0(filename(), ".xlsx")
            }
        },
        content = function(file) {
            if (input$tbl_yml_switch == "yaml") {
                txt <- markr::tbl2yaml(tbl(), open = FALSE)
                write(txt, file)
            } else {
                rio::export(tbl(), file)
            }
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
    })

    # delete_col ----
    observeEvent(input$delete_col, {
        debug_msg("delete_col: ", input$col_name)
        t <- tbl()
        for (n in input$col_name) {
            t[n] <- NULL
        }
        tbl(t)
    })

    # rename_col ----
    observeEvent(input$rename_col, {
        debug_msg("rename_col: ", input$col_name[[1]])
        oldname <- trimws(input$col_name[[1]])
        newname <- trimws(input$col_val)
        if (newname == "") return()
        if (oldname == "") return()
        t <- dplyr::rename(tbl(), !!newname := dplyr::all_of(oldname))
        tbl(t)
        updateTextInput(session, "col_val", value = "")
    })
    
    # reorder_col ----
    observeEvent(input$reorder_col, {
        debug_msg("reorder_col: ", input$col_name)
        t <- tbl()
        if (!all(input$col_name %in% names(t))) return()
        
        new_order <- c(input$col_name, setdiff(names(t), input$col_name))
        tbl(t[new_order])
    })
    
    observeEvent(input$temp_file, { # temp_file ----
        debug_msg("temp_file:", input$temp_file$name)
        
        tryCatch({
            temp_txt <- readLines(input$temp_file$datapath) %>%
                paste(collapse = "\n")
            updateTextAreaInput(session, "template_text", value = temp_txt)
        }, error = function(e) {
            shinyjs::alert(e$message)
        })
        
    }, ignoreNULL = TRUE)
    
    observeEvent(input$test_render, { # test_render ----
        debug_msg("test_render")
        
        template_file <- tempfile(fileext = ".Rmd")
        write(input$template_text, template_file)
        save_file <- tempfile(fileext = ".html")
        
        test_html <- tryCatch({
            marks <- tbl()
            
            if (length(input$group_by) == 0) {
                gb <- 1:nrow(marks)
            } else {
                gb <- marks[, input$group_by]
            }
            x <- by(marks, gb, function(ind) { ind })
            ind <- sample(x, 1)[[1]]
    
            options(knitr.duplicate.label = 'allow')
            rmarkdown::render(template_file,
                              output_file = save_file,
                              intermediates_dir = tempdir(),
                              quiet = TRUE,
                              envir = new.env(),
                              encoding = "UTF-8")
            
            readLines(save_file) %>% 
                paste(collapse = "\n") %>%
                HTML()
        }, error = function(e) {
            shinyjs::alert(e)
            
            return ("")
        })
        
        output$test_output <- renderUI(test_html)
        
        if (test_html != "") updateTabsetPanel(session, "temp_tabset", selected = "html_output")
        invisible()
    })
    
    output$dl_rmd <- downloadHandler( #dl_rmd ----
        filename = function() {
            debug_msg("dl_rmd")
            "template.Rmd"
        },
        content = function(file) {
            write(input$template_text, file)
        }
    )
    
    output$dl_all <- downloadHandler( #dl_all ----
        filename = function() {
            debug_msg("dl_all")
            "feedback.zip"
        },
        content = function(file) {
            my_wd<-getwd()
            on.exit(setwd(my_wd))
            
            template_file <- tempfile(fileext = ".Rmd")
            write(input$template_text, template_file)

            tryCatch({
                dir_path <- file.path(tempdir(), "fb")
                if (dir.exists(dir_path)) unlink(dir_path, TRUE)
                dir.create(dir_path)
                setwd(dir_path)
                
                markr::make_feedback(tbl(), 
                                     template_file,
                                     input$custom_filename, 
                                     input$group_by)
                
                setwd(tempdir())
                utils::zip(file, "fb")
            }, error = function(e) {
                shinyjs::alert(e)
            })
        }
    )

}

shinyApp(ui, server)
