tbl <- system.file("basic", "marks.csv", package = "markr")
yaml <- system.file("basic", "fb.yml", package = "markr")
temp <- system.file("basic", "template.Rmd", package = "markr")
tdir <- tempdir()

test_that("errors", {
  expect_error(make_feedback())
  expect_error(make_feedback(demo_marks))
  err <- "The file nofile does not exist"
  expect_error(make_feedback("nofile", temp), err, fixed = TRUE)
  expect_error(make_feedback(demo_marks, "nofile"), err, fixed = TRUE)
})

test_that("default", {
  skip_on_cran()
  
  wd <- getwd()
  on.exit(setwd(wd))
  setwd(tdir)
  fbdir <- file.path(tdir, "feedback")
  
  # make sure objects in global env not accessible 
  class_name = "SHOULD NOT BE USED"

  demo_marks$grade <- "A"
  op <- capture.output(
    make_feedback(demo_marks, temp, class_name = "Demo Class")
  )
  
  #f1 <- paste0(tdir, "/feedback/1.html") %>% readLines()
  # browseURL(paste0(tdir, "/feedback/2.html"))

  expect_true(file.exists(paste0(tdir, "/feedback/1.html")))
  expect_true(file.exists(paste0(tdir, "/feedback/2.html")))
  expect_true(file.exists(paste0(tdir, "/feedback/3.html")))
  expect_true(file.exists(paste0(tdir, "/feedback/4.html")))
  expect_true(file.exists(paste0(tdir, "/feedback/5.html")))

  if (dir.exists(fbdir)) unlink(fbdir, recursive = TRUE)
})

test_that("filename", {
  skip_on_cran()
  
  fbdir <- paste0(tdir, "/fb")
  filename = paste0(fbdir, "/[ID]")
  demo_marks$grade <- "A"
  op <- capture.output(
    make_feedback(demo_marks, temp, filename, class_name = "Demo Class")
  )

  expect_true(file.exists(paste0(tdir, "/fb/S1.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S2.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S3.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S4.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S5.html")))

  if (dir.exists(fbdir)) unlink(fbdir, recursive = TRUE)
})


test_that("tibble", {
  skip_on_cran()
  
  fbdir <- paste0(tdir, "/fb")
  filename = paste0(fbdir, "/[ID].html")
  dm <- tibble::as_tibble(demo_marks)
  dm$grade <- dm$mark
  op <- capture.output(
    make_feedback(dm, temp, filename, "ID", class_name = "Demo Class")
  )

  expect_true(file.exists(paste0(tdir, "/fb/S1.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S2.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S3.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S4.html")))
  expect_true(file.exists(paste0(tdir, "/fb/S5.html")))

  if (dir.exists(fbdir)) unlink(fbdir, recursive = TRUE)
})


test_that("filter", {
  skip_on_cran()
  
  fbdir <- file.path(tdir, "fb")
  filename = file.path(fbdir, "[ID]")
  demo_marks$grade <- "A"
  op <- capture.output(
    make_feedback(demo_marks, temp, filename, 
                  class_name = "Demo Class",
                  filter_by = c(ID = "S2"))
  )
  
  expect_true(!file.exists(file.path(tdir, "fb/S1.html")))
  expect_true(file.exists(file.path(tdir, "fb/S2.html")))
  expect_true(!file.exists(file.path(tdir, "fb/S3.html")))
  expect_true(!file.exists(file.path(tdir, "fb/S4.html")))
  expect_true(!file.exists(file.path(tdir, "fb/S5.html")))
  
  if (dir.exists(fbdir)) unlink(fbdir, recursive = TRUE)
})
