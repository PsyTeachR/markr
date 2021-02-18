test_that("glasgow22", {
  g22 <- glasgow22()

  expect_true(is.character(g22$letters))
  expect_true(is.numeric(g22$numbers))
})

test_that("convert", {
  g22 <- glasgow22()

  # no to
  expect_equal(convert_grades(g22$letters), g22$numbers)
  expect_equal(convert_grades(g22$numbers),
               c(NA, NA, NA, g22$letters[4:26]))

  # opposite to
  expect_equal(convert_grades(g22$letters, "numbers"), g22$numbers)
  expect_equal(convert_grades(g22$numbers, "letters"),
               c(NA, NA, NA, g22$letters[4:26]))

  # same to
  expect_equal(convert_grades(g22$letters, "letters"), g22$letters)
  expect_equal(convert_grades(g22$numbers, "numbers"), g22$numbers)

  # uppercase
  expect_equal(convert_grades(tolower(g22$letters), "letters"), g22$letters)

})


test_that("custom scale", {
  scale <- data.frame(
    letters = LETTERS[1:6],
    numbers = c(4, 3, 2, 1, 0, NA)
  )

  expect_equal(LETTERS[1:5], convert_grades(4:0, scale = scale))
  expect_equal(c(4:0, NA), convert_grades(LETTERS[1:6], scale = scale))
  expect_equal(c(4:0, NA), convert_grades(letters[1:6], scale = scale))
})
