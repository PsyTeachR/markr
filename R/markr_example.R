#' Make example directory
#'
#' @param example which example (basic or glasgow)
#' @param dir the directory to save the example files in
#'
#' @return opens the Rmd files for editing
#' @export
#'
#' @examples
#' \dontrun{
#' markr_example("glasgow")
#' }
markr_example <- function(example = c("basic", "glasgow"),
                          dir = paste0(example, "_example")) {
  example <- match.arg(example)
  
  dir.create(dir,
             recursive = TRUE,
             showWarnings = FALSE)

  demodir <- system.file(example, package = "markr")
  demofiles <- list.files(demodir)
  fromfiles <- paste0(demodir, "/", demofiles)
  tofiles <- paste0(dir, "/", demofiles)
  file.copy(fromfiles, tofiles)

  # open all Rmds
  rmds <- grepl("\\.Rmd$", tofiles)
  filenames <- tofiles[rmds]
  if(rstudioapi::hasFun("navigateToFile")){
    sapply(filenames, rstudioapi::navigateToFile)
  } else {
    sapply(filenames, utils::file.edit)
  }
  
  invisible()
}
