## code to prepare `demo_marks` dataset goes here

library(faux)
library(dplyr)

# simulate some marks
set.seed(8675309)
n <- 5
bnames <- ukbabynames::ukbabynames$name %>% trimws() %>% unique()
demo_marks <- sim_design(
  within = list(categories = c("KR", "CE", "AC")),
  n = n, mu = c(0, 0.5, .2), r = 0.5,
  id = "ID",
  plot = FALSE
) %>%
  mutate_if(is.numeric, norm2likert,
            prob = c(.1, .2, .3, .4)) %>%
  mutate(name = sample(bnames, n),
         marker = "Prof. X",
         question = c("A", "B", "B", "A", "A"),
         mark = KR+CE+AC,
         mark = (mark - mean(mark))/sd(mark),
         mark = norm2binom(mark, 4, .7),
         feedback = "Lorem ipsum...",
         ) %>%
  select(ID, name, marker, question, KR, CE, AC, mark, feedback)

usethis::use_data(demo_marks, overwrite = TRUE)

demo_marks %>%
  select(-feedback) %>%
  readr::write_csv("inst/example/marks.csv")
