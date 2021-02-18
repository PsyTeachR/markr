#' Make example directory
#'
#' @param dir the directory to save the example files in
#'
#' @return opens the demo.Rmd file for editing
#' @export
#'
#' @examples
#' \dontrun{
#' markr_example("demo")
#' }
markr_example <- function(dir = "markr_example") {
  dir.create(dir,
             recursive = TRUE,
             showWarnings = FALSE)

  demodir <- system.file("example", package = "markr")
  demofiles <- list.files(demodir)
  fromfiles <- paste0(demodir, "/", demofiles)
  tofiles <- paste0(dir, "/", demofiles)
  x <- file.copy(fromfiles, tofiles)

  filename <- paste0(dir, "/demo.Rmd")
  if(rstudioapi::hasFun("navigateToFile")){
    rstudioapi::navigateToFile(filename)
  } else {
    utils::file.edit(filename)
  }
}
