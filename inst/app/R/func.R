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

# create a demo marking table
demo_tbl <- function(n = 20) {
  # get relatively common names
  bn <- ukbabynames::ukbabynames$name[ukbabynames::ukbabynames$n > 20] %>%
    unique()
  
  dat <- dplyr::tibble(
    `Student ID` = paste0(sample(11111:99999, n), sample(LETTERS, n, T)),
    name = sample(bn, n),
    class = "PSY101",
    question = sample(c("A", "B"), n, T),
    grade = sample(LETTERS[1:5], n, T, c(20, 40, 25, 10, 5)),
    KR = sample(1:4, n, T),
    CE = sample(1:4, n, T),
    AC = sample(1:4, n, T),
    feedback = sample(stringr::sentences, n, T)
  )
  
}

## constants ----

## . template_text ----
template_text <- '---
title: "Feedback for `r student$class`"  
date: "`r format(Sys.time(), \'%d %B, %Y\')`"  
output: 
  html_document:
    df_print: kable
---
  
```{r setup, include = FALSE}
knitr::opts_chunk$set(echo = FALSE,
                      message = FALSE,
                      warning = FALSE)
```

<style>
  html { font-size: 14px; }
  h3 { color: purple; }
</style>

**Student**: `r student$name` (`r student["Student ID"]`)  
**Question**: `r student$question`  
**Grade**: `r student$grade`

### Individual Feedback

```{r}
cols <- list(
  "KR" = "Knowledge and Research",
  "CE" = "Critical Evaluation",
  "AC" = "Academic Communication"
)
cats <- list(
  "1" = "Needs Work",
  "2" = "Acceptable",
  "3" = "Good",
  "4" = "Outstanding"
)

markr::category_table(student, cols, cats)
```

`r student$feedback`

### Generic Feedback

Here are some things that students did well:

* Thing 1
* Thing 2

Here are some things that could be improved:

* Thing 3
* Thing 4

### Grade Distribution

```{r, fig.alt="Dsitribution of grades for Questions A and B."}
markr::mark_dist(
    marks = marks, 
    mark_col = "grade", 
    facet_by = "question",
    scale = c("E", "D", "C", "B", "A")
)
```
'