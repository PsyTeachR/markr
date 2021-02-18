test_that("basic", {
  marks <- data.frame(ID = 1:3, K = 1:3, E = 2, C = 1:3)
  cols <- c(K = "Knowledge", E = "Evaluation", C = "Communication")
  cats <- c("0" = "Missing", "1" = "Bad", "2" = "OK", "3" = "Good")

  p1 <- cat_dist(marks, cols, cats) %>% print()
  expect_equal(class(p1), c("gg", "ggplot"))
  p2 <- cat_dist(marks, cols, cats, "cat") %>% print()
  expect_equal(class(p2), c("gg", "ggplot"))
})
