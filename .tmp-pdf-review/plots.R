library(ggplot2)
library(dplyr)
survey_data <- readRDS("data/sample.rds")
zone_colors <- c(Urban = "#48C9B0", Rural = "#117864")

before <- ggplot(survey_data, aes(x = Income, weight = wk)) +
  geom_histogram(aes(y = after_stat(density), fill = Zone), bins = 30,
                 alpha = 0.5, position = "identity") +
  scale_fill_manual(values = zone_colors) +
  labs(title = "Antes: histogramas superpuestos",
       x = "Ingreso mensual per cápita", y = "Densidad", fill = "Zona") +
  theme_bw()

after <- ggplot(survey_data, aes(x = Income, weight = wk)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30,
                 fill = "#48C9B0") +
  facet_wrap(~Zone, ncol = 1,
             labeller = labeller(Zone = c(Urban = "Urbana", Rural = "Rural"))) +
  labs(title = "Después: paneles separados, con escalas comunes",
       x = "Ingreso mensual per cápita", y = "Densidad") +
  theme_bw()

ggsave(file.path(Sys.getenv("VIZ_DIR"), "histograma-zona-antes.png"), before,
       width = 9, height = 5.5, dpi = 150)
ggsave(file.path(Sys.getenv("VIZ_DIR"), "histograma-zona-despues.png"), after,
       width = 9, height = 7, dpi = 150)
