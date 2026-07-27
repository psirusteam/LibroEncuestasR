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

  # Conserva las figuras PDF que ya existían y retira solo las creadas por
  # esta compilación, para no mezclar recursos del PDF con el libro HTML.
  figure_pdfs_before <- list.files(
    "figures",
    pattern = "\\.pdf$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  on.exit({
    figure_pdfs_after <- list.files(
      "figures",
      pattern = "\\.pdf$",
      full.names = TRUE,
      ignore.case = TRUE
    )
    generated_figure_pdfs <- setdiff(
      figure_pdfs_after,
      figure_pdfs_before
    )

    if (length(generated_figure_pdfs) > 0) {
      unlink(generated_figure_pdfs, force = TRUE)
    }
  }, add = TRUE)

  run_quarto(c(
    "render",
    ".",
    "--profile",
    "pdf",
    "--to",
    "pdf"
  ))

  pdf_output <- file.path("docs", "Libro.pdf")

  if (!file.exists(pdf_output)) {
    stop("Quarto terminó sin crear ", pdf_output, ".")
  }

  message("PDF generado: ", normalizePath(pdf_output, winslash = "/"))
}

render_pdf()
