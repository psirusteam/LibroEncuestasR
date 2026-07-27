active_profiles <- trimws(strsplit(
  Sys.getenv("QUARTO_PROFILE"),
  ",",
  fixed = TRUE
)[[1]])

if ("pdf" %in% active_profiles) {
  pdf_source <- file.path("output", "pdf", "Libro.pdf")
  pdf_output <- file.path("docs", "Libro.pdf")
  pdf_cache_dir <- file.path("_freeze", ".pdf-cache")
  pdf_cache <- file.path(pdf_cache_dir, "Libro.pdf")

  if (!file.exists(pdf_source)) {
    stop("Quarto terminó sin crear ", pdf_source, ".")
  }

  dir.create(dirname(pdf_output), recursive = TRUE, showWarnings = FALSE)
  dir.create(pdf_cache_dir, recursive = TRUE, showWarnings = FALSE)

  if (!file.copy(
    from = pdf_source,
    to = pdf_output,
    overwrite = TRUE,
    copy.date = TRUE
  )) {
    stop("No se pudo guardar el PDF en ", pdf_output, ".")
  }

  if (!file.copy(
    from = pdf_source,
    to = pdf_cache,
    overwrite = TRUE,
    copy.date = TRUE
  )) {
    stop("No se pudo crear la copia técnica para conservar el PDF.")
  }

  source_md5 <- unname(tools::md5sum(pdf_source))
  output_md5 <- unname(tools::md5sum(pdf_output))
  cache_md5 <- unname(tools::md5sum(pdf_cache))

  if (
    !identical(source_md5, output_md5) ||
    !identical(source_md5, cache_md5)
  ) {
    stop(
      "La verificación del PDF falló. Se conserva el archivo temporal en ",
      pdf_source,
      "."
    )
  }

  project_dir <- normalizePath(
    ".",
    winslash = "/",
    mustWork = TRUE
  )
  output_dir <- normalizePath(
    "output",
    winslash = "/",
    mustWork = TRUE
  )
  expected_output_dir <- paste0(project_dir, "/output")

  paths_match <- if (.Platform$OS.type == "windows") {
    identical(tolower(output_dir), tolower(expected_output_dir))
  } else {
    identical(output_dir, expected_output_dir)
  }

  if (!paths_match) {
    stop("No se eliminó la carpeta temporal porque su ruta no es la esperada.")
  }

  unlink(output_dir, recursive = TRUE, force = TRUE)

  if (dir.exists(output_dir)) {
    stop("No se pudo eliminar la carpeta temporal ", output_dir, ".")
  }

  message("PDF generado: ", normalizePath(pdf_output, winslash = "/"))
  quit(save = "no", status = 0)
}

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

pdf_cache <- file.path("_freeze", ".pdf-cache", "Libro.pdf")
pdf_output <- file.path("docs", "Libro.pdf")

if (file.exists(pdf_cache)) {
  if (!file.copy(
    from = pdf_cache,
    to = pdf_output,
    overwrite = TRUE,
    copy.date = TRUE
  )) {
    stop("No se pudo restaurar ", pdf_output, " después de compilar el HTML.")
  }

  if (!identical(
    unname(tools::md5sum(pdf_cache)),
    unname(tools::md5sum(pdf_output))
  )) {
    stop("La verificación de ", pdf_output, " falló después de compilar el HTML.")
  }
}
