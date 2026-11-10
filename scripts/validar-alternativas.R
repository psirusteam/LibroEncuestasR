# Comprobaciones de coherencia de los ejemplos reorganizados.
# Ejecutar desde la raíz del proyecto, en una sesión limpia de R.
library(survey)
library(srvyr)
library(dplyr)
options(survey.lonely.psu = "adjust")

survey_data <- readRDS("data/sample.rds")
survey_design <- survey_data %>%
  as_survey_design(strata = Stratum, ids = PSU, weights = wk, nest = TRUE) %>%
  mutate(
    poor = ifelse(Poverty != "NotPoor", 1, 0),
    unemployed = ifelse(Employment == "Unemployed", 1, 0)
  )
labor_force_subset <- survey_design %>%
  filter(Age >= 15, Employment %in% c("Employed", "Unemployed")) %>%
  mutate(Sex = factor(Sex, levels = c("Female", "Male")))

stopifnot(nrow(survey_data) == 2605, ncol(survey_data) == 20)
stopifnot(all(na.omit(survey_data$Poverty) %in% c("NotPoor", "Extreme", "Relative")))
stopifnot(all(labor_force_subset$variables$Employment %in% c("Employed", "Unemployed")))
stopifnot(!anyNA(labor_force_subset$variables$unemployed))

regional <- svyby(~unemployed, ~Region, labor_force_subset, svymean, covmat = TRUE,
                  na.rm = TRUE, vartype = c("se", "ci"))
contrasts <- list(
  north_center = c(North = 1, Central = -1),
  south_center = c(South = 1, Central = -1),
  west_east = c(West = 1, East = -1)
)
result <- svycontrast(regional, contrasts)
estimates <- setNames(regional$unemployed, regional$Region)
manual <- c(estimates["North"] - estimates["Central"],
            estimates["South"] - estimates["Central"],
            estimates["West"] - estimates["East"])
stopifnot(isTRUE(all.equal(as.numeric(coef(result)), as.numeric(manual))))
v <- vcov(regional)
stopifnot(isTRUE(all.equal(unname(SE(result)[1]),
  unname(sqrt(v["North", "North"] + v["Central", "Central"] -
              2 * v["North", "Central"])))))

employment_sizes <- survey_design %>% filter(!is.na(Employment)) %>%
  group_by(Employment, Poverty) %>% summarise(size = survey_total())
known_total <- survey_design %>% filter(!is.na(Employment)) %>%
  summarise(size = survey_total())
stopifnot(isTRUE(all.equal(sum(employment_sizes$size), known_total$size)))
stopifnot("Inactive" %in% employment_sizes$Employment)

poverty_cv <- survey_design %>% group_by(Region) %>%
  summarise(proportion = survey_mean(poor, na.rm = TRUE, vartype = "cv"))
rural_female <- survey_design %>% filter(Zone == "Rural", Sex == "Female") %>%
  group_by(Region) %>%
  summarise(proportion = survey_mean(poor, na.rm = TRUE, vartype = "cv"))
stopifnot(nrow(poverty_cv) == 5, !anyDuplicated(poverty_cv$Region),
          all(is.finite(poverty_cv$proportion_cv)),
          nrow(rural_female) == 5, !anyDuplicated(rural_female$Region),
          all(is.finite(rural_female$proportion_cv)))

heads <- survey_design %>% filter(PersonID == "idPer01") %>%
  mutate(Sex = factor(Sex, levels = c("Female", "Male")))
income_regions <- svyby(~Income, ~Region, survey_design, svymean, covmat = TRUE)
income_contrasts <- svycontrast(income_regions, contrasts)
head_ratios <- svyby(~Income, ~Sex, heads, svyratio,
                    denominator = ~Expenditure, covmat = TRUE)
ratio_contrast <- svycontrast(head_ratios, list(sex_difference = c(Female = 1, Male = -1)))
odds <- svymean(~interaction(Sex, poor), survey_design, na.rm = TRUE)
or <- svycontrast(odds, quote(
  (`interaction(Sex, poor)Female.0` / `interaction(Sex, poor)Female.1`) /
    (`interaction(Sex, poor)Male.0` / `interaction(Sex, poor)Male.1`)))

cat("VALIDACIÓN DE EJEMPLOS ALTERNATIVOS\n")
cat("Dimensiones, categorías, dominios, sumas, contrastes y mapas: OK\n")
cat("Grados de libertad del diseño:", degf(survey_design), "\n")
cat("Tasas regionales de desocupación:\n"); print(regional)
cat("Contrastes regionales de desocupación:\n"); print(result)
cat("Tasa y prueba de desocupación por sexo:\n")
print(svyby(~unemployed, ~Sex, labor_force_subset, svymean))
print(svyttest(unemployed ~ Sex, labor_force_subset))
cat("Prueba por condición de actividad:\n")
print(svychisq(~Sex + Employment, survey_design %>% filter(!is.na(Employment)), statistic = "F"))
cat("Razón de odds:\n"); print(or)
cat("Contrastes de ingreso por región:\n"); print(income_contrasts)
cat("Prueba de ingreso en jefaturas:\n"); print(svyttest(Income ~ Sex, heads))
cat("Contraste de razones Female - Male:\n"); print(ratio_contrast)
cat("CV de proporciones de pobreza:\n"); print(poverty_cv)
cat("Pobreza femenina rural y CV:\n"); print(rural_female)
cat("Mediana del gasto por zona:\n")
print(survey_design %>% group_by(Zone) %>%
        summarise(median = survey_median(Expenditure, qrule = "math", vartype = c("se", "ci"))))

# Evaluar el código real de los diagramas: una compilación puede terminar
# aunque ggplot descarte una capa por una dependencia opcional ausente.
library(ggplot2)
library(patchwork)
zone_colors <- c(Urban = "#48C9B0", Rural = "#117864")
lines <- readLines("chapters/04-Continuas-alternativa.qmd", encoding = "UTF-8")
first <- grep("^```\\{r fig-boxplot-zona-sexo,", lines)
last <- first + which(lines[(first + 1):length(lines)] == "```")[1]
invisible(eval(parse(text = lines[(first + 1):(last - 1)])))
for (plot in list(weighted_zone_boxplot, weighted_sex_boxplot)) {
  boxes <- ggplot_build(plot)$data[[1]]
  stopifnot(nrow(boxes) == 2L, all(is.finite(boxes$middle)),
            all(boxes$lower <= boxes$middle),
            all(boxes$middle <= boxes$upper))
}
cat("Diagramas de caja: cuatro cajas visibles y cuantiles ordenados, OK.\n")
# Verify the actual map setup from the chapter and its regional joins.
map_lines <- readLines("chapters/03-Categoricas-alternativa.qmd", encoding = "UTF-8")
map_first <- grep("^```\\{r mapas-setup,", map_lines)
map_last <- map_first + which(map_lines[(map_first + 1):length(map_lines)] == "```")[1]
map_code <- paste(map_lines[(map_first + 1):(map_last - 1)], collapse = "\n")
map_code <- gsub("../data/", "data/", map_code, fixed = TRUE)
invisible(eval(parse(text = map_code)))
map_check <- left_join(bigcity_shape, poverty_cv, by = "Region")
stopifnot(nrow(map_check) == nrow(bigcity_shape),
          !anyNA(map_check$proportion), !anyNA(map_check$proportion_cv))
cat("Correspondencia geográfica y unión sin regiones faltantes: OK.\n")
cat("Todas las comprobaciones pasaron.\n")
