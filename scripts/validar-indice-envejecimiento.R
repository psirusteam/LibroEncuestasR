# Ejecutar desde la raíz. Verifica el índice CEPAL (60+ / 0-14) y su varianza.
suppressPackageStartupMessages({
  library(survey)
  library(srvyr)
  library(dplyr)
})
options(survey.lonely.psu = "adjust")
data <- readRDS("data/sample.rds")
stopifnot(all(data$Age[!is.na(data$Age)] >= 0))
survey_design <- data %>%
  as_survey_design(strata = Stratum, ids = PSU, weights = wk, nest = TRUE)

lines <- readLines("chapters/04-Continuas-alternativa.qmd", encoding = "UTF-8")
for (label in c("cod-indice-envejecimiento", "cod-indice-envejecimiento-zona")) {
  first <- which(lines == paste0("```{r ", label, "}"))
  stopifnot(length(first) == 1L)
  last <- first + which(lines[(first + 1):length(lines)] == "```")[1]
  eval(parse(text = lines[(first + 1):(last - 1)]))
}
observed <- data[!is.na(data$Age), ]
stopifnot(nrow(aging_design) == nrow(observed))
manual <- function(d) {
  100 * sum(d$wk * (d$Age >= 60)) / sum(d$wk * (d$Age < 15))
}
stopifnot(isTRUE(all.equal(aging_index$aging, manual(observed))))
check_variance <- function(design, estimate) {
  totals <- svytotal(~older_person + young_person, design)
  ratio <- svycontrast(totals, quote(100 * older_person / young_person))
  stopifnot(isTRUE(all.equal(as.numeric(SE(ratio)), estimate$aging_se)))
}
check_variance(aging_design, aging_index)
for (zone in c("Rural", "Urban")) {
  estimate <- zone_aging_index[zone_aging_index$Zone == zone, ]
  stopifnot(isTRUE(all.equal(estimate$aging, manual(observed[observed$Zone == zone, ]))))
  check_variance(subset(aging_design, Zone == zone), estimate)
}
print(aging_index)
print(zone_aging_index)
cat("Validación correcta: cortes de edad, dominio, cocientes ponderados y varianzas.\n")
