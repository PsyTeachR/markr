test_that("examples", {
  let <- glasgow22()$letters
  num <- glasgow22()$numbers
  n <- 100
  df <- data.frame(
    A = rep(c("A1", "A2"), each = n),
    B = rep(c("B1", "B2"), times = n),
    letter = sample(let, 2*n, T),
    number = sample(num, 2*n, T)
  )
  df$first <- gsub('[0-9]', '', df$letter)
  df$first <- ifelse(nchar(df$first) == 2, "X", df$first)

  p1 <- mark_dist(df, "letter", scale = let) %>% print()
  expect_equal(class(p1), c("gg", "ggplot"))
  p2 <- mark_dist(df, "number") %>% print()
  expect_equal(class(p2), c("gg", "ggplot"))
  p3 <- mark_dist(df, "letter", fill_col = "first", scale = let) %>% print()
  expect_equal(class(p3), c("gg", "ggplot"))
})
