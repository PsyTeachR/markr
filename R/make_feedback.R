#' Create Feedback Reports
#'
#' \code{make_feedback} creates feedback files from a template .Rmd file
#'
#' @param marks data frame of marks or path to file
#' @param template path to the .Rmd template file for feedback
#' @param filename path to save files, defaults to "feedback/\[group_by columns\]", but you can reference any column names inside square brackets (e.g., "assignment_\[moodle_id\]_/\[Student ID\]")
#' @param group_by columns to group by (e.g., if the marking file contains multiple rows per student) defaults to grouping by row if NULL
#' @param filter_by optional vector for filtering, e.g. c(ID = 1) or c(question = "A")
#' @param quiet print a message for each rendering
#' @param ... extra data to make available in the template file
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' # saves each feedback file in a separate folder with the ID
#' make_feedback(demo_marks, "template.Rmd", "fb/[ID]/exam_Q[question]", "ID")
#' }

make_feedback <- function(marks, template, filename = NULL, 
                          group_by = NULL, filter_by = NULL, 
                          quiet = FALSE, ...) {
  # error checks ----
  if (!file.exists(template)) {
    stop("The file ", template, " does not exist")
  }

  if (is.character(marks)) {
    if (!file.exists(marks)) {
      stop("The file ", marks, " does not exist")
    }
    marks <- rio::import(marks)
  }
  
  # filter marks ----
  if (!is.null(filter_by) && all(names(filter_by) %in% names(marks))) {
    for (i in seq_along(filter_by)) {
      keep <- marks[[names(filter_by[i])]] == filter_by[i]
      marks <- marks[keep, , drop = FALSE]
    }
  }

  # group marks by row or group_by columns ----
  if (is.null(group_by)) {
    # group by row number
    marks$.rownumber. <- 1:nrow(marks)
    group_by <- ".rownumber."
  }

  if (!is.numeric(group_by)) {
    group_by <- which(names(marks) %in% group_by)
  }

  # create filenames ----
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
  
  # knit feedback ----

  # prevent duplicate label problem when knitting from Rmd
  kdl <- getOption('knitr.duplicate.label')
  on.exit(options(knitr.duplicate.label = kdl))
  options(knitr.duplicate.label = "allow")
  
  if (!quiet) {
    pb <- progress::progress_bar$new(
      format = "  rendering :what [:bar] :percent (:elapsed)",
      total = nrow(marks), clear = FALSE)
    pb$tick(len = 0, tokens = list(what = ""))
    Sys.sleep(0.5) # hack to make the 0% bar show up
    pb$tick(len = 0, tokens = list(what = ""))
  }

  x <- by(marks, marks[, group_by], function(student) {
    # get filename and create subdirs
    suppressWarnings({
      # warns about unused arguments
      fname <- c(list(file_fmt), student[1, ]) %>%
        do.call(sprintf, .)
    })
    dir.create(dirname(fname),
               recursive = TRUE,
               showWarnings = FALSE)
    
    new_env <- new.env()
    list2env(list(...), envir = new_env)

    rmarkdown::render(
      template,
      output_file = fname,
      quiet = TRUE,
      intermediates_dir = tempdir(),
      envir = new_env
    )
    
    if (!quiet) {
      pb$tick(len = nrow(student), 
              tokens = list(what = paste0(sub(wd, "", fname))))
    }
  })
  pb$terminate()

  invisible(TRUE)
}
