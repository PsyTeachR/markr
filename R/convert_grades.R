#' Convert Grades to Marks
#'
#' \code{convert_grades} convert letter grades to numeric marks
#'
#' @param grades vector of letter or number grades
#' @param to convert to `letters` or `numbers` (default NA converts to other type)
#' @param scale conversion table containing `letters` and `numbers`
#'
#' @return vector
#'
#' @examples
#' convert_grades("A1") # convert from letter to number
#' convert_grades(1:22) # convert from number to letter
#'
#' # make all letter grades the same case
#' convert_grades(c("a1", "B2", "c3"), "letters")
#' @export

convert_grades <- function(grades, to = NA, scale = glasgow22()) {
  stopifnot(length(grades) > 0)

  scale <- utils::type.convert(scale, as.is = TRUE)

  if (!"numbers" %in% colnames(scale) || !is.numeric(scale$numbers)) {
    stop("The scale needs a numeric column called 'numbers'")
  }
  if (!"letters" %in% colnames(scale) || !is.character(scale$letters)) {
    stop("The scale needs a character column called 'letters'")
  }

  if (all(grades %in% scale$numbers)) {
    if (!is.na(to) && to == "numbers") {
      # leave as is
      converted <- grades
    } else {
      # convert to letters
      not_na <- !is.na(scale$numbers)
      let <- scale$letters[not_na]
      names(let) <- scale$numbers[not_na]
      let <- let[!is.na(let)]
      converted <- dplyr::recode(grades, !!!let)
    }
  } else if (all(toupper(grades) %in% toupper(scale$letters))) {
    if (!is.na(to) && to == "letters") {
      # leave as is (uppercase)
      converted <- toupper(grades)
    } else {
      # convert to numbers
      not_na <- !is.na(scale$letters)
      num <- scale$numbers[not_na]
      names(num) <- scale$letters[not_na]
      num <- num[!is.na(num)]
      d <- ifelse(is.integer(scale$numbers),
                  NA_integer_, NA_real_)
      converted <- dplyr::recode(toupper(grades),
                                 !!!num, .default = d)
    }
  } else {
    stop("Some grades are not in the scale")
  }

  converted
}

#'Glasgow 22-Point Marking Scale
#'
#'\code{glasgow22} The University of Glasgow 22-point marking scale conversion table
#'
#'@return data frame
#'@examples
#'glasgow22()
#'@export

glasgow22 <- function() {
  data.frame(
    letters =c("CR", "CW", "MV", "H", "G2", "G1", "F3", "F2", "F1",
            "E3", "E2", "E1", "D3", "D2", "D1",
            "C3", "C2", "C1", "B3", "B2", "B1",
            "A5", "A4", "A3", "A2", "A1"),
    numbers = c(NA, NA, NA, 0:22)
  )
}
