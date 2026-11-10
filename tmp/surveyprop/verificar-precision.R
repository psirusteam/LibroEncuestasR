suppressPackageStartupMessages({library(survey); library(srvyr); library(dplyr)})
options(survey.lonely.psu='adjust')
survey_data <- readRDS('data/sample.rds')
survey_design <- survey_data %>% as_survey_design(strata=Stratum,ids=PSU,weights=wk,nest=TRUE) %>% mutate(poor=as.numeric(Poverty!='NotPoor'),unemployed=as.numeric(Employment=='Unemployed'))
labor_force_subset <- survey_design %>% filter(Age>=15,Employment %in% c('Employed','Unemployed'))
lines <- readLines('chapters/03-Categoricas-alternativa.qmd')
for (label in c('cod-tasa-desocupacion-edad-mujer','cod-pobreza-edad')) {
 a <- which(startsWith(lines,paste0('```{r ',label,'}')))
 b <- a+which(lines[(a+1):length(lines)]=='```')[1]
 eval(parse(text=lines[(a+1):(b-1)]))
}
for (i in seq_len(nrow(female_unemployment_rate))) {
 age <- as.character(female_unemployment_rate$age_range[i])
 direct <- svymean(~unemployed,subset(labor_force_subset,Sex=='Female' & CatAge==age))
 stopifnot(abs(coef(direct)-female_unemployment_rate$unemployment_rate[i])<1e-10,
           abs(SE(direct)-female_unemployment_rate$unemployment_rate_se[i])<1e-10)
}
for (i in seq_len(nrow(poverty_age_table))) {
 age <- as.character(poverty_age_table$age_group[i])
 direct <- svymean(~poor,subset(survey_design,CatAge==age))
 stopifnot(abs(coef(direct)-poverty_age_table$poverty_rate[i])<1e-10,
           abs(SE(direct)-poverty_age_table$poverty_rate_se[i])<1e-10)
}
stopifnot(nrow(female_unemployment_rate)==9L,nrow(poverty_age_table)==10L,
          sum(female_unemployment_rate$unemployment_rate==0)==4L,
          sum(poverty_age_table$poverty_rate==0)==1L)
# Audit only executable code, ignoring explanatory prose.
in_chunk <- FALSE; code <- character()
for (line in lines) {
 if (startsWith(line,'```{r')) {in_chunk <- TRUE; next}
 if (line=='```') {in_chunk <- FALSE; next}
 if (in_chunk) code <- c(code,line)
}
stopifnot(!any(grepl('survey_mean\\s*\\(',code)))
cat('OK: tasas y errores estándar coinciden; grupos sin eventos conservados; ningún chunk usa survey_mean.\n')
