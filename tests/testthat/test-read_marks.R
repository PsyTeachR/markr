tbl <- system.file("basic", "marks.csv", package = "markr")
yaml <- system.file("basic", "fb.yml", package = "markr")
cols <- c("ID", "name", "marker", "question",
          "KR", "CE", "AC", "mark")

test_that("errors", {
  expect_null(read_marks())
  expect_error(read_marks("noexist.csv")) # make nicer
})

test_that("tbl", {
  marks <- read_marks(tbl)
  expect_equal(names(marks), cols)
})

test_that("yaml", {
  marks <- read_marks(yaml = yaml)
  expect_equal(names(marks), c("ID", "feedback"))
})

test_that("tbl and yaml", {
  marks <- read_marks(tbl, yaml, join_by = "ID")
  marks101 <- read_marks(tbl, yaml, join_by = "ID", class = "PSYCH101")

  expect_equal(names(marks), c(cols, "feedback"))
  expect_equal(names(marks101), c(cols, "feedback", "class"))

  # no join
  expect_message(read_marks(tbl, yaml), 'Joining, by = "ID"', fixed = TRUE)
})
