#!/usr/bin/env Rscript

# Renderiza el libro en Word mediante el perfil word.
# Las salidas HTML y PDF no se modifican.

render_word <- function() {
  required_files <- c(
    "_quarto.yml",
    "_quarto-word.yml",
    "scripts/quarto-run.R"
  )
  if (!all(file.exists(required_files))) {
    stop(
      "Abra QuartoESP.Rproj o establezca QuartoESP como directorio de trabajo ",
      "antes de ejecutar este archivo."
    )
  }

  source("scripts/quarto-run.R", local = environment(), encoding = "UTF-8")

  run_quarto(c(
    "render",
    ".",
    "--profile",
    "word",
    "--to",
    "docx"
  ))

  word_source <- file.path("output", "word", "Libro.docx")
  word_output <- file.path("docs", "Libro.docx")

  if (!file.exists(word_source)) {
    stop("Quarto terminó sin crear ", word_source, ".")
  }

  dir.create(dirname(word_output), recursive = TRUE, showWarnings = FALSE)

  if (!file.copy(
    from = word_source,
    to = word_output,
    overwrite = TRUE,
    copy.date = TRUE
  )) {
    stop("No se pudo guardar el documento Word en ", word_output, ".")
  }

  if (!identical(
    unname(tools::md5sum(word_source)),
    unname(tools::md5sum(word_output))
  )) {
    stop(
      "La verificación del documento Word falló. Se conserva el archivo ",
      "temporal en ",
      word_source,
      "."
    )
  }

  project_dir <- normalizePath(
    ".",
    winslash = "/",
    mustWork = TRUE
  )
  word_output_dir <- normalizePath(
    file.path("output", "word"),
    winslash = "/",
    mustWork = TRUE
  )
  expected_word_output_dir <- paste0(project_dir, "/output/word")

  paths_match <- if (.Platform$OS.type == "windows") {
    identical(
      tolower(word_output_dir),
      tolower(expected_word_output_dir)
    )
  } else {
    identical(word_output_dir, expected_word_output_dir)
  }

  if (!paths_match) {
    stop(
      "No se eliminó la salida temporal porque su ruta no es la esperada."
    )
  }

  unlink(word_output_dir, recursive = TRUE, force = TRUE)

  if (dir.exists(word_output_dir)) {
    stop("No se pudo eliminar la carpeta temporal ", word_output_dir, ".")
  }

  output_root <- "output"
  if (dir.exists(output_root)) {
    remaining_files <- list.files(
      output_root,
      all.files = TRUE,
      no.. = TRUE
    )
    if (length(remaining_files) == 0) {
      unlink(output_root, recursive = TRUE, force = TRUE)
    }
  }

  message(
    "Documento Word generado: ",
    normalizePath(word_output, winslash = "/")
  )
}

render_word()
