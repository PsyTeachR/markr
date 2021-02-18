#' Category Distributions
#'
#' If you have columns in your marking spreadsheet that give category labels to each of several criteria (e.g., marking the criteria Knowledge, Evaluation and Communication with the categories 0-4), you can plot an overview of this.
#'
#' @param marks table with criteria columns
#' @param cols a named vector of the criteria (names are the marks column names and values are the text to display)
#' @param cats a named vector of the marking categories (names are the value in marks and values are the text to display)
#' @param xaxis what to plot on the x-axis ("col" = the evaluation columns, "cat" = the marking category labels)
#' @param facet_by columns for facet graphs
#'
#' @return ggplot object
#' @export
#'
#' @examples
#' cols <- c(KR = "Knowledge", CE = "Evaluation", AC = "Communication")
#' cats <- c("0" = "Missing", "1" = "Bad", "2" = "OK", "3" = "Good", "4" = "Excellent")
#' cat_dist(demo_marks, cols, cats)
#' cat_dist(demo_marks, cols, cats, "cat", "question")
cat_dist <- function(marks, cols, cats = NULL,
                     xaxis = c("col", "cat"),
                     facet_by = NULL) {
  xaxis <- match.arg(xaxis)
  # column and category name checks
  if (is.null(names(cols))) names(cols) <- cols
  if (is.null(names(cats))) names(cats) <- cats

  # check if column names are in table
  missing <- setdiff(names(cols), names(marks))
  if (length(missing) > 0) {
    stop("Columns are missing:", paste(missing, ","))
  }

  # reshape marks ---
  lmarks <- marks %>%
    tidyr::gather(col, cat, names(cols)) %>%
    dplyr::mutate(
      col = dplyr::recode(col, !!!cols),
      col = factor(col, levels = cols),
      cat = dplyr::recode(cat, !!!cats),
      cat = factor(cat, levels = cats)
    ) %>%
    dplyr::filter(!is.na(cat))

  # set y-axis breaks to reasonable integers ----
  total <- nrow(marks)/length(scale)
  by <- dplyr::case_when(
    total < 10 ~ 1,
    total < 50 ~ 5,
    TRUE ~ 10
  )
  ybreaks <- seq(0, nrow(marks), by)

  # plot ----
  if (xaxis == "col") {
    p <- ggplot2::ggplot(lmarks, ggplot2::aes(col, fill = cat)) +
      ggplot2::geom_bar()
  } else if (xaxis == "cat") {
    p <- ggplot2::ggplot(lmarks, ggplot2::aes(cat, fill = cat)) +
      ggplot2::geom_bar(show.legend = FALSE) +
      ggplot2::geom_hline(yintercept = 0, colour = "grey")
    facet_by <- c("col", facet_by) %>% unique()
  }
  p <- p  +
    ggplot2::scale_fill_viridis_d(drop = FALSE) +
    ggplot2::scale_x_discrete(drop = FALSE) +
    ggplot2::scale_y_continuous(breaks = ybreaks) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank()
    ) +
    ggplot2::facet_grid(facet_by) +
    ggplot2::labs(x = "", y = "", fill = "")

  p
}
