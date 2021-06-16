#' Convert table to YAML
#'
#' @param tbl The data table or path to a data table
#' @param filename The name of a file to save to
#' @param ... Extra column values to be added
#' @param open Whether to open the file in a text editor
#'
#' @return opens file or returns YAML text
#' @export
#'
#' @examples
#' yaml <- tbl2yaml(demo_marks, class = "PSYCH1001")
#'
tbl2yaml <- function(tbl = NULL, filename = NULL, ..., open = TRUE) {
  if (is.character(tbl) && file.exists(tbl)) {
    tname <- tbl
    tbl <- rio::import(tname)
  }

  extra <- list(...)
  if (is.null(tbl) && length(extra) > 0) {
    # no data, so make an empty data frame
    # with the number of rows from the max length ...
    n <- sapply(extra, length) %>% max()
    tbl <- data.frame(matrix(NA, ncol=1, nrow=n))[-1]
  }

  if (!is.data.frame(tbl)) {
    stop("tbl must be a data frame or the path to one")
  }

  ## add extras
  for (i in seq_along(extra)) {
    nm <- names(extra)[i]
    if (nm %in% names(tbl)) warning("Overwriting column ", nm)
    tbl[nm] <- extra[[i]]
  }

  # converts integer columns to int to avoid .0 in yaml
  y <- utils::type.convert(tbl, as.is = TRUE) %>%
    yaml::as.yaml(column.major = FALSE) %>%
    gsub(": .na\n", ": \n", ., fixed = TRUE) %>%
    gsub("'(#[^\n]*)'\n", "\\1\n", .)

  ## save file
  if (!is.null(filename)) {
    if (!grepl("\\.yml$", filename)) {
      filename <- paste0(filename, ".yml")
    }

    write(y, filename)

    if (isTRUE(open)) {
      if(rstudioapi::hasFun("navigateToFile")){
        rstudioapi::navigateToFile(filename)
      } else {
        utils::file.edit(filename)
      }
    }

    file.exists(filename)
  } else {
    if (isTRUE(open) && rstudioapi::hasFun("documentNew")) {
      rstudioapi::documentNew(y, type = "sql") %>% invisible()
    } else {
      y
    }
  }
}

