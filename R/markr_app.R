#' Launch Shiny App
#'
#' The app will eventually be a fully interactive way to create marking feedback from spreadsheets. It currently only lets you create YAML files interactively.
#'
#' @param ... arguments to pass to shiny::runApp
#'
#' @export
#'
#' @examples
#' \dontrun{ markr_app() }
#'
markr_app <- function(...) {
  pckgs <- c("shiny", "shinydashboard", "shinyjs", "DT")
  names(pckgs) <- pckgs
  req_pckgs <- sapply(pckgs, requireNamespace, quietly = TRUE)
  
  if (all(req_pckgs)) {
    shiny::runApp(appDir = system.file("app", package = "markr"), ...)
  } else {
    warning("You need to install the following packages to run the app: ",
            paste(names(req_pckgs[!req_pckgs]), collapse = ", "))
  }
}
