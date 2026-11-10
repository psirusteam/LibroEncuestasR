# Ejecutar desde la raíz: actualiza solo CatAge en data/sample.rds.
path <- "data/sample.rds"
sample <- readRDS(path)
stopifnot(is.numeric(sample$Age), any(!is.na(sample$Age)),
          all(is.finite(sample$Age[!is.na(sample$Age)])),
          all(sample$Age[!is.na(sample$Age)] >= 0))
breaks <- seq(0, 10 * (floor(max(sample$Age, na.rm = TRUE) / 10) + 1), by = 10)
sample$CatAge <- cut(
  sample$Age,
  breaks = breaks,
  labels = paste(head(breaks, -1), tail(breaks, -1) - 1, sep = "-"),
  right = FALSE,
  ordered_result = TRUE
)
attr(sample$CatAge, "label") <- "Ten-year age group (years)"
saveRDS(sample, path)
cat("CatAge actualizado:", paste(levels(sample$CatAge), collapse = ", "), "\n")
