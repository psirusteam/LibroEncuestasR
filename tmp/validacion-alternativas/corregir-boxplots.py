from pathlib import Path
import re
root = Path(__file__).resolve().parents[2]
path = root / 'chapters/04-Continuas-alternativa.qmd'
s = path.read_text(encoding='utf-8')
start = s.index('Los cuartiles y la mediana corresponden')
end = s.index('Además de las herramientas disponibles en `ggplot2`', start)
s = s[:start] + '''Los cuartiles y la mediana corresponden a los conceptos de la sección @sec-estimacion-de-percentiles. Las cajas resumen dispersión y no son intervalos de confianza de la mediana. Para construirlas se calculan primero cuantiles ponderados con `survey_quantile()`, sin solicitar sus intervalos (`vartype = NULL`). Esta opción permite representar los resultados con `geom_boxplot(stat = "identity")` sin requerir paquetes adicionales para el cálculo de cuantiles.

Las columnas `q_q25`, `q_q50` y `q_q75` contienen los cuartiles y la mediana. Los extremos de los bigotes se definen como el mínimo y máximo observados, restringidos a las cercas situadas a 1,5 rangos intercuartílicos de los cuartiles. Esta figura omite los puntos extremos fuera de las cercas; el ejemplo posterior con `svyboxplot()` permite representarlos. `coord_flip()` presenta las cajas horizontalmente y las paletas mantienen los colores de los grupos.

```{r fig-boxplot-zona-sexo, fig.cap="Cuartiles ponderados del ingreso per cápita por zona y sexo", fig.align='center', out.width='90%', fig.width=8, fig.height=4, echo=TRUE}
zone_box <- survey_design %>%
  group_by(Zone) %>%
  summarise(q = survey_quantile(
    Income, quantiles = c(0, .25, .5, .75, 1),
    vartype = NULL, qrule = "math"
  )) %>%
  mutate(
    whisker_low = pmax(q_q00, q_q25 - 1.5 * (q_q75 - q_q25)),
    whisker_high = pmin(q_q100, q_q75 + 1.5 * (q_q75 - q_q25))
  )

weighted_zone_boxplot <- ggplot(zone_box, aes(
  x = Zone, fill = Zone, ymin = whisker_low, lower = q_q25,
  middle = q_q50, upper = q_q75, ymax = whisker_high
)) +
  geom_boxplot(stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = zone_colors) +
  labs(x = "Zona", y = "Ingreso mensual per cápita", fill = "Zona") +
  theme_bw() + theme(legend.position = "none")

sex_box <- survey_design %>%
  group_by(Sex) %>%
  summarise(q = survey_quantile(
    Income, quantiles = c(0, .25, .5, .75, 1),
    vartype = NULL, qrule = "math"
  )) %>%
  mutate(
    whisker_low = pmax(q_q00, q_q25 - 1.5 * (q_q75 - q_q25)),
    whisker_high = pmin(q_q100, q_q75 + 1.5 * (q_q75 - q_q25))
  )

sex_colors <- c(Male = "#5DADE2", Female = "#2874A6")
weighted_sex_boxplot <- ggplot(sex_box, aes(
  x = Sex, fill = Sex, ymin = whisker_low, lower = q_q25,
  middle = q_q50, upper = q_q75, ymax = whisker_high
)) +
  geom_boxplot(stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = sex_colors) +
  labs(x = "Sexo", y = "Ingreso mensual per cápita", fill = "Sexo") +
  theme_bw() + theme(legend.position = "none")

weighted_zone_boxplot | weighted_sex_boxplot
```

''' + s[end:]
path.write_text(s, encoding='utf-8')
print('Diagramas de caja calculados con cuantiles ponderados de srvyr.')
