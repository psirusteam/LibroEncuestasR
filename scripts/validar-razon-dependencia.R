suppressPackageStartupMessages({library(survey);library(srvyr);library(dplyr)})
options(survey.lonely.psu="adjust")
data<-readRDS("data/sample.rds")
stopifnot(!anyNA(data$Age),all(is.finite(data$Age)),all(data$Age>=0))
survey_design<-data %>%
 as_survey_design(strata=Stratum,ids=PSU,weights=wk,nest=TRUE)
lines<-readLines("chapters/04-Continuas-alternativa.qmd",encoding="UTF-8")
for(label in c("cod-razon-dependencia","cod-razon-dependencia-zona","cod-contraste-dependencia")){
 a<-which(startsWith(lines,paste0("```{r ",label,"}")))
 b<-a+which(lines[(a+1):length(lines)]=="```")[1]
 eval(parse(text=lines[(a+1):(b-1)]))
}
manual<-function(d)100*sum(d$wk*(d$Age<15|d$Age>=65))/sum(d$wk*(d$Age>=15&d$Age<65))
stopifnot(isTRUE(all.equal(dependency_ratio$dependency,manual(data))))
for(z in c("Rural","Urban"))stopifnot(isTRUE(all.equal(zone_dependency_ratio$dependency[zone_dependency_ratio$Zone==z],manual(data[data$Zone==z,]))))
stopifnot(isTRUE(all.equal(as.numeric(coef(zone_dependency_joint)),zone_dependency_ratio$dependency)))
stopifnot(isTRUE(all.equal(as.numeric(SE(zone_dependency_joint)),zone_dependency_ratio$dependency_se)))
stopifnot(isTRUE(all.equal(as.numeric(vcov(dependency_difference)),as.numeric(t(dependency_coefficients)%*%dependency_covariance%*%dependency_coefficients))))
totals<-svytotal(~dependent_age+reference_age,dependency_design)
national<-svycontrast(totals,quote(100*dependent_age/reference_age))
stopifnot(isTRUE(all.equal(as.numeric(SE(national)),dependency_ratio$dependency_se)))
print(dependency_ratio);print(zone_dependency_ratio);print(dependency_contrast_table)
cat("Validación: edades completas; cocientes ponderados, varianzas y covarianzas correctos.\n")
