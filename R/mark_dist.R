#' Marking Distribution Graph
#'
#' \code{mark_dist} create a graph of the marking distribution
#'
#' @param marks data frame of marking info
#' @param mark_col column where the mark is found
#' @param fill_col column for setting fill
#' @param facet_by columns for facet graphs
#' @param scale vector of values for the x-axis (full range of the marking scale), defaults to alphabetical or numeric ordering of existing data
#' @param na.rm remove NA values in the mark_col
#'
#' @return ggplot
#' @examples
#' mark_dist(demo_marks, "mark", scale = 0:5)
#' @export

mark_dist <- function(marks, mark_col, fill_col = mark_col, facet_by = NULL, scale = NULL, na.rm = TRUE) {
  # make sure cols  are strings
  if (is.numeric(mark_col)) {
    mark_col <- names(marks)[mark_col]
  }
  if (is.numeric(fill_col)) {
    fill_col <- names(marks)[fill_col]
  }
  if (is.numeric(facet_by)) {
    facet_by <- names(marks)[facet_by]
  }

  if (na.rm) {
    # remove NA marks
    not_na <- which(!is.na(marks[[mark_col]]))
    marks <- marks[not_na, ]
  }

  vmarks <- marks[[mark_col]] %>%
    utils::type.convert(as.is=TRUE)

  # set scale and factor marks ----
  if (!is.null(scale)) { # do nothing
  } else if (is.integer(vmarks)) {
    scale <- min(vmarks, na.rm = T):max(vmarks, na.rm = T)
  } else {
    scale <- unique(vmarks) %>% sort()
  }
  marks[mark_col] <- factor(vmarks, levels = scale)

  # set y-axis breaks to reasonable integers
  total <- nrow(marks)/length(scale)
  by <- dplyr::case_when(
    total < 10 ~ 1,
    total < 50 ~ 5,
    TRUE ~ 10
  )
  ybreaks <- seq(0, nrow(marks), by)

  # plot ----
  p <- ggplot2::ggplot(marks, ggplot2::aes_string(x = mark_col, fill = fill_col)) +
    ggplot2::geom_bar(show.legend = FALSE) +
    ggplot2::scale_fill_viridis_d(drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE) +
    ggplot2::scale_y_continuous(breaks = ybreaks) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank()
    ) +
    ggplot2::facet_grid(facet_by, labeller = ggplot2::label_both) +
    ggplot2::labs(x = "", y = "")

  p
}
