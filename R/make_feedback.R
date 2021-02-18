#' Create Feedback Reports
#'
#' \code{make_feedback} creates feedback files from a template .Rmd file
#'
#' @param marks data frame of marks or path to file
#' @param template path to the .Rmd template file for feedback
#' @param filename path to save files, defaults to "feedback/\[group_by columns\]", but you can reference any column names inside square brackets (e.g., "assignment_\[moodle_id\]_/\[Student ID\]")
#' @param group_by columns to group by (e.g., if the marking file contains multiple rows per student) defaults to grouping by row if NULL
#' @param quiet print a message for each rendering
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' # saves each feedback file in a separate folder with the ID
#' make_feedback(demo_marks, "template.Rmd", "fb/[ID]/exam_Q[question]", "ID")
#' }

make_feedback <- function(marks, template, filename = NULL, group_by = NULL, quiet = FALSE) {
  if (!file.exists(template)) {
    stop("The file ", template, " does not exist")
  }

  if (is.character(marks)) {
    if (!file.exists(marks)) {
      stop("The file ", marks, " does not exist")
    }
    marks <- rio::import(marks)
  }

  if (is.null(group_by)) {
    # group by row number
    marks$.rownumber. <- 1:nrow(marks)
    group_by <- ".rownumber."
  }

  if (!is.numeric(group_by)) {
    group_by <- which(names(marks) %in% group_by)
  }

  wd <- paste0(getwd(), "/")

  if (is.null(filename)) {
    file_fmt <- paste0("feedback/%",
                       paste(group_by, collapse = "$s_%"),
                       "$s.html")
  } else {
    file_fmt <- filename
    for (i in seq_along(marks)) {
      file_fmt <- sprintf("[%s]", names(marks)[i]) %>%
        gsub(paste0("%",i,"$s"), file_fmt, fixed = TRUE)
      file_fmt <- sprintf("[%s]", as.character(i)) %>%
        gsub(paste0("%",i,"$s"), file_fmt, fixed = TRUE)
    }
  }

  if (!grepl("\\.html$", file_fmt)) {
    file_fmt <- paste0(file_fmt, ".html")
  }
  if (substr(file_fmt, 1, 1) != "/") {
    file_fmt <- paste0(wd, file_fmt)
  }

  # check if [xxx] remains and warn
  if (grepl("\\[.+\\]", file_fmt)) {
    warning("The filename referenced a column that doesn't exist")
  }

  # prevent duplicate label problem when knitting from Rmd
  kdl <- getOption('knitr.duplicate.label')
  on.exit(options(knitr.duplicate.label = kdl))
  options(knitr.duplicate.label = "allow")

  x <- by(marks, marks[, group_by], function(ind) {
    # get filename and create subdirs
    fname <- c(list(file_fmt), ind[1, ]) %>%
      do.call(sprintf, .)
    dir.create(dirname(fname),
               recursive = TRUE,
               showWarnings = FALSE)

    systime <- system.time(
      rmarkdown::render(
        template,
        output_file = fname,
        quiet = TRUE
      )
    )
    etime <- round(systime['elapsed'], 2)
    if (!quiet) {
      print(paste0(sub(wd, "", fname), " (", etime, " s)"))
    }
  })

  invisible(TRUE)
}
