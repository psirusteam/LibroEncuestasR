#!/usr/bin/env Rscript

# Renderiza solo el PDF mediante el perfil pdf. La salida HTML no se modifica.

render_pdf <- function() {
  required_files <- c(
    "_quarto.yml",
    "_quarto-pdf.yml",
    "scripts/quarto-run.R"
  )
  if (!all(file.exists(required_files))) {
    stop(
      "Abra QuartoESP.Rproj o establezca QuartoESP como directorio de trabajo ",
      "antes de ejecutar este archivo."
    )
  }

  source("scripts/quarto-run.R", local = environment(), encoding = "UTF-8")

  # Los procesos de R iniciados por Quarto deben reconocer los acentos de
  # la ruta del proyecto, también al leer archivos geográficos con sf.
  if (.Platform$OS.type == "windows") {
    previous_locale <- Sys.getenv("LC_ALL", unset = NA_character_)
    on.exit({
      if (is.na(previous_locale)) {
        Sys.unsetenv("LC_ALL")
      } else {
        Sys.setenv(LC_ALL = previous_locale)
      }
    }, add = TRUE)
    Sys.setenv(LC_ALL = "English_United States.utf8")
  }

  # Las figuras PDF son dependencias del archivo TeX y deben conservarse
  # para recompilarlo. Se ejecutan los chunks para regenerar las ausentes.

  run_quarto(c(
    "render",
    ".",
    "--profile",
    "pdf",
    "--to",
    "pdf",
    "--execute"
  ))

  pdf_output <- file.path("docs", "Libro.pdf")

  if (!file.exists(pdf_output)) {
    stop("Quarto terminó sin crear ", pdf_output, ".")
  }

  message("PDF generado: ", normalizePath(pdf_output, winslash = "/"))
}

render_pdf()
