source_dir <- "figures"
publish_dir <- file.path("docs", "figures")

if (dir.exists(source_dir)) {
  dir.create(publish_dir, recursive = TRUE, showWarnings = FALSE)

  figure_files <- list.files(source_dir, all.files = FALSE, full.names = TRUE)
  if (length(figure_files) > 0) {
    invisible(file.copy(
      from = figure_files,
      to = publish_dir,
      overwrite = TRUE,
      recursive = TRUE,
      copy.date = TRUE
    ))
  }
}

chapter_figure_dirs <- Sys.glob(file.path("docs", "chapters", "*_files", "figure-html"))
if (length(chapter_figure_dirs) > 0) {
  unlink(chapter_figure_dirs, recursive = TRUE, force = TRUE)
}

chapter_asset_dirs <- Sys.glob(file.path("docs", "chapters", "*_files"))
for (asset_dir in chapter_asset_dirs) {
  remaining_files <- list.files(asset_dir, all.files = TRUE, no.. = TRUE)
  if (length(remaining_files) == 0) {
    unlink(asset_dir, recursive = TRUE, force = TRUE)
  }
}
