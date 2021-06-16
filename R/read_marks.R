#' Read marks from spreadsheet and/or yaml
#'
#' @param tbl path of tabular data (e.g., excel, csv)
#' @param yaml path of yaml data
#' @param join_by column name to join by if reading both tabular and yaml
#' @param ... Extra column values to be added
#'
#' @return data table
#' @export
#'
#' @examples
#' tbl <- system.file("basic", "marks.csv", package = "markr")
#' yaml <- system.file("basic", "fb.yml", package = "markr")
#' marks <- read_marks(tbl, yaml, join_by = "ID")
#' marks101 <- read_marks(tbl, yaml, join_by = "ID", class = "PSYCH101")
read_marks <- function(tbl = NULL, yaml = NULL, join_by = NULL, ...) {
  marks <- NULL
  tbl_marks <- NULL
  yaml_marks <- NULL

  if (!is.null(tbl)) {
    stopifnot(file.exists(tbl))
    tbl_marks <- rio::import(tbl)
  }

  if (!is.null(yaml)) {
    stopifnot(file.exists(yaml))
    y <- yaml::read_yaml(yaml)

    # convert to data frame
    df <- list(val = y)
    class(df) <- c("tbl_df", "data.frame")
    attr(df, "row.names") <- .set_row_names(length(y))

    yaml_marks <- tidyr::unnest_wider(df, "val")
  }

  if (!is.null(tbl_marks) && !is.null(yaml_marks)) {
    marks <- dplyr::full_join(tbl_marks, yaml_marks, by = join_by)
  } else if (!is.null(tbl_marks)) {
    marks <- tbl_marks
  } else if (!is.null(yaml_marks)) {
    marks <- yaml_marks
  }

  ## add extras
  extra <- list(...)
  for (i in seq_along(extra)) {
    nm <- names(extra)[i]
    if (nm %in% names(marks)) warning("Overwriting column ", nm)
    marks[nm] <- extra[[i]]
  }

  marks
}
