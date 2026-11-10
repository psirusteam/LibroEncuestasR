# Ejecutar desde la raíz. Contrasta los chunks con cálculos ponderados
# independientes y con la linealización de un cociente de totales.
suppressPackageStartupMessages({
  library(survey)
  library(srvyr)
  library(dplyr)
})
options(survey.lonely.psu = "adjust")
data <- readRDS("data/sample.rds")
eligible <- with(data, !is.na(Age) & Age >= 15 & !is.na(Employment))
stopifnot(all(data$Employment[eligible] %in%
                c("Unemployed", "Inactive", "Employed")))
survey_design <- data %>%
  as_survey_design(strata = Stratum, ids = PSU, weights = wk, nest = TRUE)

lines <- readLines("chapters/04-Continuas-alternativa.qmd", encoding = "UTF-8")
for (label in c("cod-dependencia-economica", "cod-dependencia-economica-zona")) {
  a <- which(lines == paste0("```{r ", label, "}"))
  stopifnot(length(a) == 1L)
  b <- a + which(lines[(a + 1):length(lines)] == "```")[1]
  eval(parse(text = lines[(a + 1):(b - 1)]))
}
manual <- function(d) {
  100 * sum(d$wk * (d$Employment %in% c("Unemployed", "Inactive"))) /
    sum(d$wk * (d$Employment == "Employed"))
}
observed <- data[eligible, ]
stopifnot(nrow(economic_dependency_design) == nrow(observed))
stopifnot(isTRUE(all.equal(
  economic_dependency_ratio$dependency, manual(observed)
)))
for (zone in c("Rural", "Urban")) {
  domain_data <- observed[observed$Zone == zone, ]
  reported <- zone_economic_dependency_ratio[
    zone_economic_dependency_ratio$Zone == zone, ]
  stopifnot(isTRUE(all.equal(reported$dependency, manual(domain_data))))
  domain_design <- subset(economic_dependency_design, Zone == zone)
  domain_totals <- svytotal(~not_employed + employed, domain_design)
  domain_ratio <- svycontrast(domain_totals, quote(100 * not_employed / employed))
  stopifnot(isTRUE(all.equal(as.numeric(SE(domain_ratio)), reported$dependency_se)))
}
totals <- svytotal(~not_employed + employed, economic_dependency_design)
ratio <- svycontrast(totals, quote(100 * not_employed / employed))
stopifnot(isTRUE(all.equal(as.numeric(SE(ratio)), economic_dependency_ratio$dependency_se)))
print(economic_dependency_ratio)
print(zone_economic_dependency_ratio)
cat("Validación correcta: dominio, cocientes ponderados y errores estándar.\n")
