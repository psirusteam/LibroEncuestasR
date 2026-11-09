library(tidyverse)
library(survey)
library(srvyr)
library(patchwork)
options(survey.lonely.psu = "adjust")
survey_data <- readRDS("data/sample.rds")
survey_design <- survey_data %>% as_survey_design(
  strata = Stratum, ids = PSU, weights = wk, nest = TRUE
)
zone_colors <- c(Urban = "#48C9B0", Rural = "#117864")
zone_box <- survey_design %>%
  group_by(Zone) %>%
  summarise(q = survey_quantile(
    Income, quantiles = c(0, .25, .5, .75, 1),
    vartype = NULL, qrule = "math"
  )) %>%
  mutate(
    whisker_low = pmax(q_q00, q_q25 - 1.5 * (q_q75 - q_q25)),
    whisker_high = pmin(q_q100, q_q75 + 1.5 * (q_q75 - q_q25))
  )
weighted_zone_boxplot <- ggplot(zone_box, aes(
  x = Zone, fill = Zone, ymin = whisker_low, lower = q_q25,
  middle = q_q50, upper = q_q75, ymax = whisker_high
)) + geom_boxplot(stat = "identity") + coord_flip() +
  scale_fill_manual(values = zone_colors) +
  labs(x = "Zona", y = "Ingreso mensual per cápita", fill = "Zona") +
  theme_bw() + theme(legend.position = "none")
sex_box <- survey_design %>%
  group_by(Sex) %>%
  summarise(q = survey_quantile(
    Income, quantiles = c(0, .25, .5, .75, 1),
    vartype = NULL, qrule = "math"
  )) %>%
  mutate(
    whisker_low = pmax(q_q00, q_q25 - 1.5 * (q_q75 - q_q25)),
    whisker_high = pmin(q_q100, q_q75 + 1.5 * (q_q75 - q_q25))
  )
sex_colors <- c(Male = "#5DADE2", Female = "#2874A6")
weighted_sex_boxplot <- ggplot(sex_box, aes(
  x = Sex, fill = Sex, ymin = whisker_low, lower = q_q25,
  middle = q_q50, upper = q_q75, ymax = whisker_high
)) + geom_boxplot(stat = "identity") + coord_flip() +
  scale_fill_manual(values = sex_colors) +
  labs(x = "Sexo", y = "Ingreso mensual per cápita", fill = "Sexo") +
  theme_bw() + theme(legend.position = "none")
figure <- weighted_zone_boxplot | weighted_sex_boxplot
ggsave(file.path(Sys.getenv("VIZ_DIR"), "boxplots-ingreso-por-zona-sexo-actual.png"), figure,
       width = 8, height = 4, dpi = 160)

