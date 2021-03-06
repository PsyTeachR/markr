% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/markr_example.R
\name{markr_example}
\alias{markr_example}
\title{Make example directory}
\usage{
markr_example(
  example = c("basic", "glasgow"),
  dir = paste0(example, "_example")
)
}
\arguments{
\item{example}{which example (basic or glasgow)}

\item{dir}{the directory to save the example files in}
}
\value{
opens the Rmd files for editing
}
\description{
Make example directory
}
\examples{
\dontrun{
markr_example("glasgow")
}
}
