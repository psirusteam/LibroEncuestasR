suppressPackageStartupMessages({library(survey);library(srvyr);library(dplyr)})
options(survey.lonely.psu = "adjust")
d <- readRDS("data/sample.rds")
survey_design <- d %>%
  as_survey_design(strata = Stratum, ids = PSU, weights = wk, nest = TRUE)

lines <- readLines("chapters/04-Continuas-alternativa.qmd", encoding="UTF-8")
for(label in c("cod-razon-sexo","cod-razon-sexo-rural")){
 a <- which(lines == paste0("```{r ",label,"}"))
 b <- a + which(lines[(a+1):length(lines)] == "```")[1]
 eval(parse(text=lines[(a+1):(b-1)]))
}
manual <- function(x) 100*sum(x$wk*(x$Sex=="Male"))/sum(x$wk*(x$Sex=="Female"))
stopifnot(isTRUE(all.equal(sex_ratio_table$ratio,manual(d))))
stopifnot(isTRUE(all.equal(rural_sex_ratio_table$ratio,manual(d[d$Zone=="Rural",]))))
for(design in list(survey_design,rural_subset)){
 design <- update(design, male=as.numeric(Sex=="Male"), female=as.numeric(Sex=="Female"))
 totals <- svytotal(~male+female,design)
 estimate <- svycontrast(totals,quote(100*male/female))
 expected <- if(nrow(design)==nrow(d)) sex_ratio_table else rural_sex_ratio_table
 stopifnot(isTRUE(all.equal(as.numeric(SE(estimate)),expected$ratio_se)))
}
print(sex_ratio_table);print(rural_sex_ratio_table)
cat("Índices y errores estándar verificados frente a cálculos independientes.\n")
