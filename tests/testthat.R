library(testthat)
library(markr)

expect_equal <- function(...) {
  testthat::expect_equal(..., check.environment=FALSE)
}

test_check("markr")
