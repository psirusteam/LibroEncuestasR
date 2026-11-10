source("scripts/quarto-run.R", encoding = "UTF-8")
run_quarto(c("render", ".", "--to", "html", "--no-clean", "--output-dir", "tmp/html-verify"))
