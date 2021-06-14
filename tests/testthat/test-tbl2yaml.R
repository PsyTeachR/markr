tbl_path <- system.file("demo", "marks.csv", package = "markr")
tbl <- read.csv(tbl_path)
filename <- tempfile()
filename_yml <- paste0(filename, ".yml")
if (file.exists(filename_yml)) unlink(filename_yml)

test_that("errors", {
  #expect_error(tbl2yaml())
  expect_error(tbl2yaml("notafile.csv", filename),
               "tbl must be a data frame or the path to one",
               fixed = TRUE)
  expect_error(tbl2yaml(1, filename),
               "tbl must be a data frame or the path to one",
               fixed = TRUE)
})

test_that("no table", {
  y <- tbl2yaml(id = 1:2, fb = "...", open = FALSE)
  comp <- "- id: 1
  fb: '...'
- id: 2
  fb: '...'
"
  expect_equal(y, comp)

  y <- tbl2yaml(id = 1:2, fb = "...\n", open = FALSE)
  comp <- "- id: 1
  fb: |
    ...
- id: 2
  fb: |
    ...
"
  expect_equal(y, comp)
})

test_that("no filename", {
  y1 <- tbl2yaml(tbl_path, open = FALSE)
  y2 <- tbl2yaml(tbl, open = FALSE)
  comp <- "- ID: S1\n  name: Mukul\n  marker: Prof. X\n  question: A\n  KR: 4\n  CE: 4\n  AC: 4\n  mark: 4\n- ID: S2\n  name: Kias\n  marker: Prof. X\n  question: B\n  KR: 4\n  CE: 3\n  AC: 2\n  mark: 3\n- ID: S3\n  name: Omair\n  marker: Prof. X\n  question: B\n  KR: 4\n  CE: 4\n  AC: 4\n  mark: 4\n- ID: S4\n  name: Ramesha\n  marker: Prof. X\n  question: A\n  KR: 1\n  CE: 2\n  AC: 2\n  mark: 1\n- ID: S5\n  name: Libby-Marie\n  marker: Prof. X\n  question: A\n  KR: 2\n  CE: 3\n  AC: 3\n  mark: 2\n"
  expect_equal(y1, comp)
  expect_equal(y2, comp)
})


test_that("ok", {
  expect_silent(tbl2yaml(tbl, filename, open = FALSE))
  expect_true(file.exists(filename_yml))
  tbl2 <- read_marks(yaml = filename_yml) %>% as.data.frame()
  expect_equal(tbl, tbl2)

  if (file.exists(filename_yml)) unlink(filename_yml)
})


test_that("add cols", {
  expect_silent(tbl2yaml(tbl, filename, class = "PSYCH", open = FALSE))
  expect_true(file.exists(filename_yml))
  tbl2 <- read_marks(yaml = filename_yml) %>% as.data.frame()
  expect_true("class" %in% names(tbl2))

  if (file.exists(filename_yml)) unlink(filename_yml)
})

test_that("overwrite cols", {
  expect_warning(tbl2yaml(tbl, filename, marker = "LISA", open = FALSE),
                 "Overwriting column marker", fixed = TRUE)
  expect_true(file.exists(filename_yml))
  tbl2 <- read_marks(yaml = filename_yml) %>% as.data.frame()
  expect_equal(unique(tbl2$marker), "LISA")

  if (file.exists(filename_yml)) unlink(filename_yml)
})
