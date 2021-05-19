#' Category Table
#'
#' @param marks table with criteria columns (only the first row will be used)
#' @param cols a named vector of the criteria (names are the marks column names and values are the text to display)
#' @param cats a named vector of the marking categories (names are the value in marks and values are the text to display)
#' @param symbol the symbol to display in the table
#' @param kable return kable (T) or data table (F)
#' @param critwidth the width of the first (criteria) column; the rest of the columns are set to equal widths
#' @param ... arguments to pass to kableExtra
#'
#' @return a kable table or a data table
#' @export
#'
#' @examples
#' marks <- data.frame(ID = 7, K = 1, E = 2, C = 3)
#' cols <- c(K = "Knowledge", E = "Evaluation", C = "Communication")
#' cats <- c("1" = "Bad", "2" = "OK", "3" = "Good")
#' category_table(marks, cols, cats) # html table
#' category_table(marks, cols, cats, "X", FALSE) # data table
#'
category_table <- function(marks, cols, cats = NULL, symbol = "*",
                           kable = TRUE, critwidth = 0.5,  ...) {
  # get column names for table
  if (is.null(names(cols))) names(cols) <- cols

  # check if column names are in table
  missing <- setdiff(names(cols), names(marks))
  if (length(missing) > 0) {
    stop("Columns are missing: ", paste(missing, ","))
  }

  # make long
  dlong <- marks[1, names(cols)] %>%
    tidyr::gather("Criteria", "cat", names(cols))

  # convert cat code to full name
  if (!is.null(cats)) {
    if (is.null(names(cats))) names(cats) <- cats
    dlong$cat <- dplyr::recode(dlong$cat, !!!cats)
    catcols <- unlist(cats) %>% unname() %>% as.character()
  } else {
    # get all possible categories and sort
    catcols <- unique(dlong$cat) %>% as.character() %>% sort()
  }

  dlong$cat <- factor(dlong$cat, catcols)
  dlong$x <- symbol
  cat_table <- tidyr::spread(dlong, "cat", "x", fill = "", drop = FALSE)
  
  # fix order of rows and columns
  cat_table$Criteria <- dplyr::recode_factor(cat_table$Criteria, !!!cols)
  cat_table <- cat_table[order(cat_table$Criteria), c("Criteria", catcols)]

  # return
  cat_width <- floor(critwidth*100/length(catcols))
  crit_width <- (100 - cat_width*length(catcols)) %>% paste0("%")
  if (kable) {
    kableExtra::kable(cat_table,
      align = c("l", rep("c", length(catcols))),
      row.names = FALSE,
      ...
    ) %>%
      kableExtra::kable_styling(
        #bootstrap_options = c("striped"),
        full_width = TRUE
      ) %>%
      kableExtra::column_spec(1, width = paste0(crit_width, "%")) %>%
      kableExtra::column_spec(2:ncol(cat_table), width = cat_width)

  } else {
    rownames(cat_table) <- NULL
    cat_table
  }
}
