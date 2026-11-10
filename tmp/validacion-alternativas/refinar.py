from pathlib import Path
import re

root = Path(__file__).resolve().parents[2]
paths = [root / 'chapters' / n for n in (
    '01-Introduccion-alternativa.qmd', '03-Categoricas-alternativa.qmd',
    '04-Continuas-alternativa.qmd')]
values = [p.read_text(encoding='utf-8') for p in paths]

# Las referencias automáticas de Quarto a secciones requieren el prefijo sec-.
referenced = set(re.findall(r'@([\w-]+)', '\n'.join(values)))
ids = set(re.findall(r'^#{1,6} .*?\{#([\w-]+)\}', '\n'.join(values), re.M))
for identifier in ids & referenced:
    if not identifier.startswith('sec-'):
        values = [s.replace('{#' + identifier + '}', '{#sec-' + identifier + '}')
                  for s in values]
        values = [re.sub(r'@' + re.escape(identifier) + r'(?![\w-])',
                         '@sec-' + identifier, s) for s in values]
values = [s.replace('en el @cap2', 'en el [capítulo 2](02-Conceptos.qmd)') for s in values]

cat = values[1]
cat = cat.replace('Poverty != "NotPoor", 1, 0', 'Poverty %in% c("Extreme", "Relative"), 1, 0') if False else cat
# Presentar el resultado del contraste regional corregido, ligado al cálculo.
cat = cat.replace('```{r cod-contrastes-desempleo-region}\nsvycontrast(',
                  '```{r cod-contrastes-desempleo-region}\nunemployment_region_differences <- svycontrast(')
cat = cat.replace('west_east = c(Occidente = 1, Oriente = -1)\n  )) %>%\n  data.frame()',
                  'west_east = c(Occidente = 1, Oriente = -1)\n  ))\nunemployment_region_differences %>% data.frame()')
cat = cat.replace('## Visualización de variables categóricas',
    'Las diferencias estimadas son `r round(100 * coef(unemployment_region_differences)[1], 2)` puntos porcentuales para Norte menos Centro, `r round(100 * coef(unemployment_region_differences)[2], 2)` para Sur menos Centro y `r round(100 * coef(unemployment_region_differences)[3], 2)` para Occidente menos Oriente. Se presentan estimaciones y errores estándar de contrastes individuales; esto no constituye una prueba conjunta ni un ajuste por comparaciones múltiples.\n\n## Visualización de variables categóricas')
cat = cat.replace('permite visualizar la distribución espacial de la población masculina en condición de pobreza.',
                  'permite visualizar la proporción de pobreza dentro de la población masculina de cada región.')
cat = cat.replace('rural, con un error estándar de 3,062,', 'rural, con un error estándar de 3.062,')
values[1] = cat

cont = values[2]
cont = cont.replace('un estimador de calibración', 'un estimador ponderado')
cont = cont.replace('de manera aproximadamente insesgada mediante el estimador de calibración [@DevilleSarndal1992], que pondera el valor observado en cada unidad por su correspondiente factor de expansión calibrado.',
    'mediante una suma ponderada; cuando los factores de expansión están calibrados, corresponde al estimador de calibración [@DevilleSarndal1992]. Se pondera el valor observado en cada unidad por su factor de expansión.')
cont = cont.replace('El error estándar de este estimador puede aproximarse mediante linealización de Taylor o, equivalentemente, mediante el método delta',
    'El error estándar de la desviación estándar puede aproximarse mediante el método delta a partir de la varianza estimada de la medida de dispersión')
cont = cont.replace('Var_se` es el error estándar de la varianza', 'Var_se` es el error estándar de la varianza')
cont = cont.replace('Dado que los intervalos de confianza de las desviaciones estándar no se superponen',
                    'Los intervalos de confianza de las desviaciones estándar no se superponen')
cont = cont.replace('Además, los intervalos de confianza de las desviaciones estándar no se superponen, lo que proporciona evidencia de que la variabilidad de los ingresos es efectivamente mayor en las áreas urbanas.',
                    'Los intervalos describen la incertidumbre de cada medida de dispersión. Para realizar una prueba formal de su diferencia se necesitaría estimar el contraste correspondiente.')
cont = cont.replace('en promedio, los hombres jefes de hogar perciben 122 dólares más que las mujeres jefes de hogar,',
                    'el ingreso per cápita asociado a hombres jefes de hogar supera aproximadamente en 122 dólares al asociado a mujeres jefas de hogar,')
cont = cont.replace('las mujeres jefas de hogar presentan un ingreso medio significativamente menor al de los hombres jefes de hogar.',
                    'el ingreso per cápita asociado a las mujeres jefas de hogar es significativamente menor que el asociado a los hombres jefes de hogar, bajo el diseño y el dominio considerados.')
cont = cont.replace('La presencia del término de covarianza es importante',
                    'La presencia del término de covarianza, ya estudiado al comparar proporciones, es importante')
cont = cont.replace('que la diferencia entre las razones estimadas es de 0.178 a favor de los hombres.',
                    'que el contraste mujeres menos hombres es aproximadamente −0,178; la razón ingreso/gasto es mayor para los hombres en este dominio.')
cont = cont.replace('Histogramas con curvas de densidad superpuestas para ingreso y gasto',
                    'Histogramas ponderados y densidades del ingreso y gasto per cápita')
cont = cont.replace('geom_histogram(aes(y = after_stat(density)))',
                    'geom_histogram(aes(y = after_stat(density)), bins = 30)')
cont = cont.replace('aes(y = after_stat(density), fill = Zone),\n    alpha',
                    'aes(y = after_stat(density), fill = Zone), bins = 30,\n    alpha')
cont = cont.replace('ylab("") +\n  ggtitle("Histograma ponderado")',
                    'labs(x = "Ingreso mensual per cápita", y = "Densidad") +\n  ggtitle("Histograma ponderado")')
cont = cont.replace('Posteriormente, `ylab("")` elimina la etiqueta del eje vertical, y `ggtitle("Histograma ponderado")` agrega un título descriptivo al gráfico.',
    'La opción `bins = 30` fija el número de intervalos. `labs()` identifica las unidades del eje horizontal y la densidad del eje vertical; el área de las barras, y no su altura aislada, representa proporciones. `ggtitle()` añade el título.')
cont = cont.replace('ylab("") +\n  ggtitle("Weighted")',
                    'labs(x = "Ingreso mensual per cápita", y = "Densidad") +\n  ggtitle("Distribución ponderada por zona")')
cont = cont.replace('Finalmente, `ylab("")` elimina la etiqueta del eje vertical, `ggtitle("Weighted")` agrega un título al gráfico.',
                    'Finalmente, `labs()` identifica los ejes y `ggtitle()` agrega el título. Se utilizan 30 intervalos y la misma escala para ambas zonas.')
cont = cont.replace('las funciones especializadas `svyhist()` y `svyboxplot()` del paquete `survey` incorporan directamente las características del diseño muestral complejo en la construcción de los gráficos.',
    'las funciones especializadas `svyhist()` y `svyboxplot()` del paquete `survey` reciben directamente el objeto de diseño para obtener distribuciones ponderadas. Sus representaciones no muestran por sí solas intervalos de confianza de todos los elementos gráficos.')
cont = cont.replace('ingreso mediano', 'gasto mediano')
values[2] = cont

for path, value in zip(paths, values):
    path.write_text(value, encoding='utf-8')
print('Referencias y presentación de resultados actualizadas.')
