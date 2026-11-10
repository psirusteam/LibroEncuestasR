# Run from the project root: Rscript scripts/create-survey-en.R
# Validate the current English dataset and regenerate its codebook without modifying it.
source_path <- "data/sample.rds"
source_md5 <- tools::md5sum(source_path)
english <- readRDS(source_path)
stopifnot(nrow(english) == 2605L, ncol(english) == 20L,
          identical(levels(english$Region), c("North", "South", "Central", "West", "East")),
          is.ordered(english$CatAge),
          identical(levels(english$CatAge), paste(seq(0, 90, 10), seq(9, 99, 10), sep = "-")),
          all(vapply(english, function(x) length(attr(x, "label")) == 1L, logical(1))),
          isTRUE(all.equal(as.numeric(english$dI), as.numeric(english$NIh / english$nIh))),
          isTRUE(all.equal(as.numeric(english$dk), as.numeric(english$dI * english$dki))))

# A readable English codebook accompanies the RDS.
rows <- vapply(names(english), function(variable) {
  x <- english[[variable]]
  categories <- if (is.factor(x)) {
    paste(levels(x), collapse = "; ")
  } else if (variable %in% c("Zone", "Sex")) {
    paste(sort(unique(x)), collapse = "; ")
  } else {
    ""
  }
  paste0("| `", variable, "` | ", attr(x, "label"), " | ",
         paste(class(x), collapse = ", "), " | ", categories, " |")
}, character(1))
writeLines(c(
  "# English survey dataset",
  "",
  "File: `data/sample.rds`.",
  "",
  sprintf("Contains %s person records and %s variables.", nrow(english), ncol(english)),
  "The dataset contains person identifiers, survey design variables, final person weights, and analysis variables. CatAge uses ten-year intervals; the other variables and their values are unchanged by this age-group update.",
  "Variable descriptions are stored in each column's `label` attribute; factor categories are stored in `levels`.",
  "Region levels are North, South, Central, West, and East. CatAge is an ordered ten-year age group derived from Age: 0-9, 10-19, 20-29, through 90-99.",
  "",
  "| Variable | English label | R class | Categories (in level order for factors) |",
  "| --- | --- | --- | --- |",
  rows,
  "",
  "## Interpretation notes",
  "",
  "Variable-label attributes describe all 20 variables using the book's documentation and sampling notation.",
  "The NIh and nIh descriptions follow conventional first-stage sampling notation; the source does not supply a separate sampling dictionary. The identities dI = NIh / nIh and dk = dI * dki were verified for every record.",
  "Income and expenditure are monthly household per-capita amounts, as documented in the book. Currency is not specified here.",
  "The existing poverty categories NotPoor, Extreme, and Relative are retained without redefining their thresholds.",
  "PersonID identifies a person within a household; use it together with HHID.",
  "",
  "## Usage",
  "",
  "```r",
  "survey_data <- readRDS(\"data/sample.rds\")",
  "attr(survey_data$Income, \"label\")",
  "levels(survey_data$Region)",
  "```",
  "",
  "Regenerate this codebook from the project root with `Rscript scripts/create-survey-en.R`."
), "data/sample_codebook.md", useBytes = TRUE)
message("Validated data/sample.rds and created data/sample_codebook.md.")
stopifnot(identical(tools::md5sum(source_path), source_md5))
