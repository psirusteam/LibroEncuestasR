find_quarto_bin <- function() {
  quarto_name <- if (.Platform$OS.type == "windows") "quarto.exe" else "quarto"

  candidates <- unique(c(
    Sys.getenv("RSTUDIO_QUARTO"),
    Sys.which("quarto"),
    if (.Platform$OS.type == "windows") {
      c(
        "C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe",
        "C:/Program Files/Quarto/bin/quarto.exe",
        file.path(
          Sys.getenv("LOCALAPPDATA"),
          "Programs/Quarto/bin/quarto.exe"
        )
      )
    },
    if (Sys.info()[["sysname"]] == "Darwin") {
      c(
        "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto",
        "/Applications/quarto/bin/quarto"
      )
    },
    if (.Platform$OS.type != "windows" &&
        Sys.info()[["sysname"]] != "Darwin") {
      c(
        "/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto",
        "/opt/quarto/bin/quarto"
      )
    }
  ))

  for (candidate in candidates) {
    if (!nzchar(candidate)) {
      next
    }

    if (dir.exists(candidate)) {
      candidate <- file.path(candidate, quarto_name)
    }

    if (file.exists(candidate)) {
      return(normalizePath(
        candidate,
        winslash = "/",
        mustWork = TRUE
      ))
    }
  }

  stop("No se encontró Quarto. Instale Quarto o use una versión reciente de RStudio.")
}

patch_quarto_html_write <- function(quarto_source) {
  needle <- "  await Deno.writeTextFile(path3, output);"
  matches <- gregexpr(needle, quarto_source, fixed = TRUE)[[1]]
  if (length(matches) != 1L || matches[[1]] == -1L) {
    stop(
      "La versión instalada de Quarto no coincide con el ajuste de escritura HTML. ",
      "Actualice el script scripts/quarto-run.R."
    )
  }

  # Windows puede mantener un HTML mapeado brevemente mientras otro proceso
  # lo lee. Reintenta solo el error 1224 y conserva los demás errores.
  replacement <- paste(c(
    "  const maxWriteAttempts = 12;",
    "  for (let attempt = 0; attempt < maxWriteAttempts; attempt++) {",
    "    try {",
    "      await Deno.writeTextFile(path3, output);",
    "      return;",
    "    } catch (error) {",
    "      if (!/\\bos error 1224\\b/.test(String(error))) throw error;",
    "      if (attempt === maxWriteAttempts - 1) {",
    "        throw new Error(",
    "          'El archivo HTML sigue bloqueado por Windows: ' + path3 +",
    "          '. Cierre las vistas previas de ese archivo y compruebe si otro programa lo mantiene abierto antes de recompilar.',",
    "          { cause: error }",
    "        );",
    "      }",
    "      if (attempt === 0) {",
    "        console.warn('Archivo HTML bloqueado temporalmente; reintentando: ' + path3);",
    "      }",
    "      await new Promise((resolve) => setTimeout(resolve, Math.min(500 * 2 ** attempt, 2000)));",
    "    }",
    "  }"
  ), collapse = "\n")

  sub(needle, replacement, quarto_source, fixed = TRUE)
}

run_quarto <- function(args) {
  quarto_bin <- find_quarto_bin()

  if (.Platform$OS.type == "windows") {
    quarto_dir <- dirname(quarto_bin)
    quarto_js <- file.path(quarto_dir, "quarto.js")
    deno_bin <- file.path(
      quarto_dir,
      "tools",
      "x86_64",
      "deno.exe"
    )
    deno_dom <- file.path(
      quarto_dir,
      "tools",
      "x86_64",
      "deno_dom",
      "plugin.dll"
    )
    quarto_share <- normalizePath(
      file.path(quarto_dir, "..", "share"),
      winslash = "/",
      mustWork = TRUE
    )

    if (!all(file.exists(c(quarto_js, deno_bin, deno_dom)))) {
      stop("La instalación de Quarto de RStudio está incompleta.")
    }

    # Quarto 1.9 escribe en UTF-8 y con saltos LF el archivo por lotes que
    # inicia Sass. cmd.exe corrompe rutas con caracteres como la á de
    # "Análisis". La copia temporal activa UTF-8 antes de leer la orden y
    # escribe finales de línea Windows (CRLF).
    quarto_source_raw <- readBin(
      quarto_js,
      what = "raw",
      n = file.info(quarto_js)$size
    )
    quarto_source <- rawToChar(quarto_source_raw)
    needle <- '["@echo off", [program, ...args].join(" ")].join("\\n")'
    replacement <- paste0(
      '["@echo off", "chcp 65001 >nul", ',
      '[program, ...args].join(" ")].join("\\r\\n")'
    )

    matches <- gregexpr(needle, quarto_source, fixed = TRUE)[[1]]
    if (identical(matches, -1L) || length(matches) != 1L) {
      stop(
        "La versión instalada de Quarto no coincide con el ajuste UTF-8 ",
        "esperado. Actualice el script scripts/quarto-run.R."
      )
    }

    quarto_source <- sub(
      needle,
      replacement,
      quarto_source,
      fixed = TRUE
    )
    quarto_source <- patch_quarto_html_write(quarto_source)
    patched_quarto <- tempfile(
      pattern = "quarto-unicode-",
      fileext = ".js"
    )
    writeBin(charToRaw(quarto_source), patched_quarto)
    on.exit(unlink(patched_quarto, force = TRUE), add = TRUE)

    env_names <- c(
      "QUARTO_BIN_PATH",
      "QUARTO_SHARE_PATH",
      "DENO_DOM_PLUGIN",
      "DENO_TLS_CA_STORE",
      "DENO_NO_UPDATE_CHECK",
      "NO_COLOR"
    )
    previous_env <- Sys.getenv(env_names, unset = NA_character_)
    on.exit({
      for (i in seq_along(env_names)) {
        if (is.na(previous_env[[i]])) {
          Sys.unsetenv(env_names[[i]])
        } else {
          do.call(
            Sys.setenv,
            setNames(list(previous_env[[i]]), env_names[[i]])
          )
        }
      }
    }, add = TRUE)

    Sys.setenv(
      QUARTO_BIN_PATH = quarto_dir,
      QUARTO_SHARE_PATH = quarto_share,
      DENO_DOM_PLUGIN = deno_dom,
      DENO_TLS_CA_STORE = "system,mozilla",
      DENO_NO_UPDATE_CHECK = "1",
      NO_COLOR = "TRUE"
    )

    deno_args <- c(
      "run",
      "--cached-only",
      "--unstable-kv",
      "--unstable-ffi",
      "--no-config",
      "--no-lock",
      "--allow-all",
      "--no-check",
      paste0(
        "--v8-flags=",
        "--enable-experimental-regexp-engine,",
        "--max-old-space-size=8192,",
        "--max-heap-size=8192,",
        "--stack-trace-limit=100"
      ),
      patched_quarto,
      args
    )

    status <- system2(command = deno_bin, args = deno_args)
  } else {
    status <- system2(
      command = quarto_bin,
      args = args
    )
  }

  if (!identical(status, 0L)) {
    stop("Quarto no pudo completar la compilación; revise los mensajes anteriores.")
  }

  invisible(status)
}
