# temp_tab ----
temp_tab <- tabItem(
  tabName = "temp_tab",
  h2("Template"),
  fileInput("temp_file", NULL, width = "100%", placeholder = "Load Template"),
  actionButton("test_render", "Test"),
  downloadButton("dl_rmd", "Download Template"),
  downloadButton("dl_all", "Render All"),
  fluidRow(
    column(6, textInput("custom_filename", "File name", "[question]/[Student ID]_fb", 
                        placeholder = "filename", width = "100%")),
    column(6, selectizeInput("group_by", "Group By", c(), multiple = TRUE, width = "100%"))
  ),
  tabsetPanel(type = "tabs", id = "temp_tabset",
              tabPanel("Rmd Template", value = "rmd_template",
                       HTML("<p>In the template, the data frame <code>ind</code> is each row of the marking table (or more than one row if you, e.g., set group_by to <code>Student ID</code> and there is more than one row per student). You can access the value in each column like this: <code>ind$grade</code> or <code>ind['Student ID']</code> (use the second format if your column names have spaces or special characters)."),
                       textAreaInput("template_text", NULL, template_text, 
                                     "100%", "400px", resize = "vertical")
              ),
              tabPanel("Test Output", value = "html_output",
                       p("Output for a randomly chosen row from the data"),
                       htmlOutput("test_output"))
  )
)
