test_that("x", {
  marks <- data.frame(ID = 7, K = 1, E = 2, C = 3)
  cols <- c(K = "Knowledge", E = "Evaluation", C = "Communication")
  cats <- c("1" = "Bad", "2" = "OK", "3" = "Good")
  symbol <- "&#10004;"
  x <- category_table(marks, cols, cats, symbol, F)
  x2 <- data.frame(
    Criteria = factor(cols),
    Bad = c(symbol, "", ""),
    OK = c("", symbol, ""),
    Good = c("", "", symbol)
  )

  expect_equivalent(x, x2)
})

test_that("case insensitivity", {
  marks <- data.frame(ID = 7, K = "Good", E = "good", C = "Bad")
  cols <- c(K = "Knowledge", E = "Evaluation", C = "Communication")
  cats <- c("Bad", "OK", "Good")
  symbol <- "&#10004;"
  x <- category_table(marks, cols, cats, symbol, F)
  x2 <- data.frame(
    Criteria = factor(cols),
    Bad = c("", "", symbol),
    OK = c("", "", ""),
    Good = c(symbol, symbol, "")
  )
  
  expect_equivalent(x, x2)
})

test_that("no cats", {
  # numeric cats
  marks <- data.frame(ID = 7, K = 1, E = 2, C = 3)
  cols <- c("K", "C", "E")
  symbol <- "&#10004;"
  x <- category_table(marks, cols, kable = F) %>% tibble::as_tibble()
  # data frame is weird with integer column headers
  x2 <- tibble::tibble(
    Criteria = factor(cols),
    "1" = c(symbol, "", ""),
    "2" = c("", "", symbol),
    "3" = c("", symbol, "")
  )
  
  expect_equivalent(x, x2)
  
  # character cats
  marks <- data.frame(ID = 7, K = "A", E = "B", C = "C")
  cols <- c("K", "C", "E")
  symbol <- "&#10004;"
  x <- category_table(marks, cols, kable = F)
  x2 <- data.frame(
    Criteria = factor(cols),
    "A" = c(symbol, "", ""),
    "B" = c("", "", symbol),
    "C" = c("", symbol, "")
  )
  
  expect_equivalent(x, x2)
})

test_that("symbol", {
  marks <- data.frame(ID = 7, E = 2, K = 1, C = 3)
  cols <- c(K = "Knowledge", E = "Evaluation", C = "Communication")
  cats <- c("1" = "Bad", "2" = "OK", "3" = "Good")
  symbol <- "x"
  x <- category_table(marks, cols, cats, symbol, F)
  x2 <- data.frame(
    Criteria = factor(cols),
    Bad = c(symbol, "", ""),
    OK = c("", symbol, ""),
    Good = c("", "", symbol)
  )

  expect_equivalent(x, x2)
})

test_that("not all cats", {
  marks <- data.frame(ID = 7, marker = "Lisa", E = 1, K = 1, C = 3)
  cols <- c(K = "Knowledge", E = "Evaluation", C = "Communication")
  cats <- c("1" = "Bad", "2" = "OK", "3" = "Good")
  symbol <- "x"
  x <- category_table(marks, cols, cats, symbol, F)
  x2 <- data.frame(
    Criteria = factor(cols),
    Bad = c(symbol, symbol, ""),
    OK = c("", "", ""),
    Good = c("", "", symbol)
  )
  
  expect_equivalent(x, x2)
})
