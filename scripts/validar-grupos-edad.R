# Ejecutar desde la raíz. Puede recibir la ruta del RDS anterior para
# comprobar que CatAge es la única columna modificada.
suppressPackageStartupMessages({
  library(survey)
  library(srvyr)
  library(dplyr)
  library(ggplot2)
})
options(survey.lonely.psu = "adjust")
sample <- readRDS("data/sample.rds")
args <- commandArgs(trailingOnly = TRUE)
if (length(args)) {
  before <- readRDS(args[1])
  stopifnot(identical(names(before), names(sample)),
            identical(before[names(before) != "CatAge"],
                      sample[names(sample) != "CatAge"]))
}
stopifnot(is.ordered(sample$CatAge),
          identical(is.na(sample$CatAge), is.na(sample$Age)),
          identical(levels(sample$CatAge),
                    paste(seq(0, 90, 10), seq(9, 99, 10), sep = "-")))
expected <- ifelse(is.na(sample$Age), NA_character_,
                   paste(10 * (sample$Age %/% 10), 10 * (sample$Age %/% 10) + 9, sep = "-"))
stopifnot(identical(as.character(sample$CatAge), expected))
survey_design <- sample %>%
  as_survey_design(strata = Stratum, ids = PSU, weights = wk, nest = TRUE)

run_chunk <- function(label) {
  lines <- readLines("chapters/03-Categoricas-alternativa.qmd", encoding = "UTF-8")
  a <- which(startsWith(lines, paste0("```{r ", label)))
  stopifnot(length(a) == 1L)
  b <- a + which(lines[(a + 1):length(lines)] == "```")[1]
  eval(parse(text = lines[(a + 1):(b - 1)]), envir = .GlobalEnv)
}
run_chunk("cod-tamano-edad}")
run_chunk("cod-tamano-edad-sexo}")
for (i in seq_len(nrow(age_population_size))) {
  group <- as.character(age_population_size$CatAge[i])
  rows <- as.character(sample$CatAge) == group
  stopifnot(age_population_size$sample_size[i] == sum(rows),
            isTRUE(all.equal(age_population_size$size[i], sum(sample$wk[rows]))))
}
for (i in seq_len(nrow(age_sex_population_size))) {
  rows <- sample$CatAge == age_sex_population_size$CatAge[i] &
    sample$Sex == age_sex_population_size$Sex[i]
  stopifnot(isTRUE(all.equal(age_sex_population_size$size[i], sum(sample$wk[rows]))))
}
stopifnot(nrow(age_population_size) == 10L,
          nrow(age_sex_population_size) == 20L,
          sum(age_population_size$sample_size) == nrow(sample),
          isTRUE(all.equal(sum(age_population_size$size), sum(sample$wk))),
          isTRUE(all.equal(sum(age_sex_population_size$size), sum(sample$wk))),
          identical(as.character(unique(age_sex_population_size$CatAge)), levels(sample$CatAge)),
          all(is.finite(age_sex_population_size$size_se)))
plot <- run_chunk("fig-piramide-poblacional,")
built <- ggplot_build(plot)
stopifnot(nrow(built$data[[1]]) == 20L,
          nrow(built$data[[2]]) == 20L,
          all(is.finite(built$data[[1]]$y)))
ggsave("/tmp/piramide-decenal.png", plot, width = 10.5, height = 9, dpi = 120)
cat("Validación correcta: solo cambia CatAge; 10 grupos y 20 combinaciones observadas; ",
    "totales y conteos coinciden con cálculos independientes; pirámide ejecutada.\n", sep = "")
print(age_population_size)

# Verifica la pobreza en los cuatro rangos específicos del ejemplo.
survey_design <- survey_design %>% mutate(poor = as.numeric(Poverty != "NotPoor"))
run_chunk("cod-pobreza-edad}")
stopifnot(nrow(poverty_age_table) == 4L,
          identical(as.character(poverty_age_table$age_group),
                    c("0-14", "15-29", "30-64", "65 años o más")))
manual_groups <- ifelse(sample$Age < 15, "0-14",
                       ifelse(sample$Age < 30, "15-29",
                              ifelse(sample$Age < 65, "30-64", "65 años o más")))
for (i in seq_len(nrow(poverty_age_table))) {
  d <- sample[manual_groups == as.character(poverty_age_table$age_group[i]), ]
  stopifnot(abs(poverty_age_table$poverty_rate[i] -
                  weighted.mean(as.numeric(d$Poverty != "NotPoor"), d$wk)) < 1e-7)
}
interior <- with(poverty_age_table, poverty_rate > 0 & poverty_rate < 1)
stopifnot(all(is.finite(poverty_age_table$poverty_rate_low[interior])),
          all(is.finite(poverty_age_table$poverty_rate_upp[interior])))
cat("Pobreza en cuatro rangos: cocientes ponderados e intervalos interiores verificados.\n")

# Mantener la convención del capítulo actual: proporciones con survey_prop().
lines <- readLines("chapters/03-Categoricas-alternativa.qmd", encoding = "UTF-8")
in_chunk <- FALSE
for (line in lines) {
  if (startsWith(line, "```{r")) { in_chunk <- TRUE; next }
  if (line == "```") { in_chunk <- FALSE; next }
  if (in_chunk) stopifnot(!grepl("survey_mean\\s*\\(", line))
}
cat("Convención survey_prop(): OK.\n")
