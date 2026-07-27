#!/usr/bin/env Rscript

# Renderiza solo el libro HTML.
# En RStudio, abra QuartoESP.Rproj y ejecute este archivo con Source.

render_html <- function() {
  required_files <- c("_quarto.yml", "scripts/quarto-run.R")
  if (!all(file.exists(required_files))) {
    stop(
      "Abra QuartoESP.Rproj o establezca QuartoESP como directorio de trabajo ",
      "antes de ejecutar este archivo."
    )
  }

  source("scripts/quarto-run.R", local = environment(), encoding = "UTF-8")

  # Evita que un perfil conservado en la sesión de RStudio se aplique al HTML.
  previous_profile <- Sys.getenv("QUARTO_PROFILE", unset = NA_character_)
  on.exit({
    if (is.na(previous_profile)) {
      Sys.unsetenv("QUARTO_PROFILE")
    } else {
      Sys.setenv(QUARTO_PROFILE = previous_profile)
    }
  }, add = TRUE)
  Sys.unsetenv("QUARTO_PROFILE")

  run_quarto(c("render", ".", "--to", "html"))

  message("HTML generado: docs/index.html")
}

render_html()
