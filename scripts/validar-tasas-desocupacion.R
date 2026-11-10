# Ejecutar desde la raíz del proyecto.
# Valida los chunks reales frente a cocientes ponderados calculados directamente.
suppressPackageStartupMessages({library(survey); library(srvyr); library(dplyr)})
options(survey.lonely.psu = "adjust")
data <- readRDS("data/sample.rds")
run_chunk <- function(path, label, env) {
  lines <- readLines(path, encoding = "UTF-8")
  first <- which(startsWith(lines, paste0("```{r ", label)))[1]
  stopifnot(!is.na(first))
  last <- first + which(lines[(first + 1):length(lines)] == "```")[1]
  invisible(eval(parse(text = lines[(first + 1):(last - 1)]), envir = env))
}
results <- list()
for (path in "chapters/03-Categoricas-alternativa.qmd") {
  env <- new.env()
  env$survey_design <- data %>%
    as_survey_design(strata = Stratum, ids = PSU, weights = wk, nest = TRUE) %>%
    mutate(unemployed = ifelse(Employment == "Unemployed", 1, 0))
  for (label in c("crear-subpoblaciones-categoricas", "cod-tasa-desocupacion-edad-mujer",
                  "cod-tasa-desocupacion-sexo", "cod-tasa-ocupacion-sexo", "cod-tab-desocupacion-sexo",
                  "cod-ttest-desocupacion-sexo", "cod-tasa-desocupacion-region",
                  "cod-vcov-desocupacion-region", "cod-contrastes-desocupacion-region")) {
    run_chunk(path, label, env)
  }
  d <- data %>% filter(Age >= 15, Employment %in% c("Employed", "Unemployed"))
  stopifnot(nrow(env$labor_force_subset) == nrow(d), nrow(d) == 1177L)
  manual <- function(x) sum(x$wk * (x$Employment == "Unemployed")) / sum(x$wk)
  for (sex in c("Female", "Male")) {
    stopifnot(isTRUE(all.equal(
      env$sex_unemployment_rate$unemployment_rate[env$sex_unemployment_rate$Sex == sex],
      manual(d[d$Sex == sex, ]), check.attributes = FALSE)))
  }
  working_age <- data %>% filter(Age >= 15)
  stopifnot(nrow(env$working_age_subset) == nrow(working_age),
            !anyNA(working_age$Employment))
  for (sex in c("Female", "Male")) {
    group <- working_age %>% filter(Sex == sex)
    direct <- sum(group$wk * (group$Employment == "Employed")) / sum(group$wk)
    estimate <- env$sex_employment_rate %>% filter(Sex == sex)
    stopifnot(isTRUE(all.equal(estimate$employment_rate, direct)),
              estimate$employment_rate_se > 0,
              estimate$employment_rate_low < direct,
              estimate$employment_rate_upp > direct)
  }
  for (region in levels(d$Region)) {
    stopifnot(isTRUE(all.equal(
      env$region_unemployment_rate$unemployed[env$region_unemployment_rate$Region == region],
      manual(d[d$Region == region, ]), check.attributes = FALSE)))
  }
  female <- d %>% filter(Sex == "Female") %>%
    mutate(age_range = factor(if_else(Age < 46, "De 15 a 45", "Mayores de 45"),
                              levels = c("De 15 a 45", "Mayores de 45")))
  for (age in as.character(unique(female$age_range))) {
    stopifnot(isTRUE(all.equal(
      env$female_unemployment_rate$unemployment_rate[env$female_unemployment_rate$age_range == age],
      manual(female[female$age_range == age, ]), tolerance = 1e-6, check.attributes = FALSE)))
  }
  regional <- setNames(env$region_unemployment_rate$unemployed, env$region_unemployment_rate$Region)
  manual_contrasts <- c(regional["North"] - regional["Central"],
                       regional["South"] - regional["Central"],
                       regional["West"] - regional["East"])
  stopifnot(isTRUE(all.equal(as.numeric(coef(env$unemployment_region_differences)),
                            as.numeric(manual_contrasts))))
  manual_sex_difference <- manual(d[d$Sex == "Male", ]) - manual(d[d$Sex == "Female", ])
  stopifnot(isTRUE(all.equal(as.numeric(env$ttest_unemployment_sex$estimate), manual_sex_difference)))
  results[[path]] <- list(employment = env$sex_employment_rate, sex = env$sex_unemployment_rate,
                         age = env$female_unemployment_rate,
                         region = env$region_unemployment_rate,
                         test = env$ttest_unemployment_sex,
                         contrasts = env$unemployment_region_differences)
}
for (key in c("employment", "sex", "age")) {
  tab <- results[[1]][[key]]
  prefix <- if (key == "employment") "employment_rate" else "unemployment_rate"
  if (key == "age") {
    stopifnot(identical(as.character(tab$age_range),
                        levels(droplevels(female$age_range))))
    stopifnot(nrow(tab) == 2L,
              all(female$age_range[female$Age == 45] == "De 15 a 45"),
              all(female$age_range[female$Age == 46] == "Mayores de 45"))
  }
  stopifnot(all(tab[[paste0(prefix, "_low")]] > 0),
            all(tab[[paste0(prefix, "_low")]] < tab[[prefix]]),
            all(tab[[paste0(prefix, "_upp")]] > tab[[prefix]]),
            all(tab[[paste0(prefix, "_upp")]] < 1))
}
appendix <- new.env()
appendix$survey_data <- data
run_chunk("chapters/A3-Imputacion.qmd", "preparar-datos-imputacion", appendix)
d <- data %>% filter(Age >= 15, Employment %in% c("Employed", "Unemployed"))
stopifnot(isTRUE(all.equal(appendix$unemployment_rate$unemployment_rate,
  sum(d$wk * (d$Employment == "Unemployed")) / sum(d$wk), check.attributes = FALSE)))
print(results[[1]])
print(appendix$unemployment_rate)
cat("Validación correcta: tasas de ocupación por sexo; tasas de desocupación por sexo, edad y región; contraste por sexo; contrastes regionales; anexo de imputación.\n")
