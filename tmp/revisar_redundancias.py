from pathlib import Path
import json, re

snapshot = json.loads(Path('tmp/redundancias-antes.json').read_text(encoding='utf8'))
changes = []

def edit(file, line, old, new):
    key = 'chapters/' + file + '.qmd'
    lines = texts[key].splitlines(keepends=True)
    assert old in lines[line-1], (file, line, old)
    lines[line-1] = lines[line-1].replace(old, new, 1)
    texts[key] = ''.join(lines)

def whole(file, line, new):
    key = 'chapters/' + file + '.qmd'
    lines = texts[key].splitlines(keepends=True)
    assert 'código computacional' in lines[line-1], (file,line)
    lines[line-1] = new + '\n'
    texts[key] = ''.join(lines)

snapshot = {Path(k).as_posix(): v for k,v in snapshot.items()}
texts = dict(snapshot)
c3='03-Categoricas-alternativa'
c4='04-Continuas-alternativa'
c5='05-Regresion'
c6='06-GLM'
c7='07-Multinivel'
a1='A1-TidyVerse'
a3='A3-Imputacion'

whole(c3,46,'El objeto `survey_data` contiene la información del archivo `sample.rds`: cada fila corresponde a una unidad observada y las columnas incluyen las variables de interés y la información del diseño muestral. El siguiente código computacional utiliza `glimpse()` para examinar el número de observaciones y variables, sus nombres, sus tipos de datos y una muestra de los valores registrados.')
edit(c3,112,'En particular, se define','El siguiente código computacional define')
edit(c3,112,' El siguiente código computacional crea las variables derivadas que se utilizarán en las estimaciones.','')
edit(c3,130,'Para los ejemplos desarrollados en este capítulo, se consideran seis subpoblaciones:','El siguiente código computacional define seis subpoblaciones para los ejemplos del capítulo:')
edit(c3,130,' El siguiente código computacional define las subpoblaciones de análisis a partir del diseño muestral.','')
edit(c3,249,'En `R`, utilizando el diseño muestral definido previamente, es posible, generar resúmenes de la información de la encuesta para cada categoría de la variable `Zone`.','El siguiente código computacional utiliza el diseño muestral definido previamente para generar resúmenes por categoría de la variable `Zone`.')
edit(c3,249,' El siguiente código computacional calcula los tamaños muestrales y poblacionales por zona, junto con las medidas de precisión.','')
edit(c3,276,'Al agrupar el objeto de diseño por `CatAge`, se obtiene','El siguiente código computacional agrupa el objeto de diseño por `CatAge` y obtiene')
edit(c3,276,' El siguiente código computacional calcula los tamaños muestrales y poblacionales por grupo de edad.','')
edit(c3,327,'En primer lugar, se excluyen','En el siguiente código computacional, primero se excluyen')
edit(c3,327,' El siguiente código computacional estima el tamaño poblacional de cada categoría de empleo y sus medidas de precisión.','')
whole(c3,381,'El siguiente código computacional estima el tamaño poblacional de cada combinación de estado ocupacional y condición de pobreza. Los resultados de la @tbl-tamano-empleo-pobreza permiten describir la asociación entre ambas variables, sin establecer una relación causal.')
whole(c3,525,'Para conocer cómo se distribuye la población masculina entre las zonas urbana y rural, el siguiente código computacional estima las proporciones de hombres según su zona de residencia, incorporando el diseño muestral previamente definido.')
edit(c3,704,'Para ello, se utiliza','El siguiente código computacional utiliza')
edit(c3,704,' El denominador es la fuerza de trabajo de ese grupo.','')
edit(c3,704,' El siguiente código computacional estima las tasas de desocupación por sexo y sus medidas de precisión.','')
whole(c3,862,'Para estimar la razón de odds definida anteriormente, primero se necesitan las proporciones conjuntas de sexo y condición de pobreza, junto con sus varianzas y covarianzas. En la interfaz de fórmulas de `survey`, `~interaction(Sex, poor)` identifica las cuatro combinaciones de estas variables. El siguiente código computacional estima sus proporciones mediante `svymean()` y organiza las estimaciones, los errores estándar y los intervalos de confianza que se presentan en la @tbl-interaccion-sexo-pobreza. El objeto resultante conserva las covarianzas necesarias para calcular después la razón de odds y su error estándar con `svycontrast()`. La @sec-contrastes-y-diferencias-de-proporciones desarrolla el uso de esta función para contrastes lineales.')
whole(c3,1019,'Las tasas por sexo, calculadas en `sex_unemployment_rate`, se presentan en la @tbl-tasa-desocupacion-sexo-prueba. El siguiente código computacional utiliza `svyttest()` del paquete `survey` para contrastar la diferencia entre las tasas de desocupación de hombres y mujeres, incorporando el diseño muestral. Luego reúne la diferencia estimada, el estadístico, el valor-*p*, los grados de libertad y el intervalo de confianza para su presentación en una tabla.')
whole(c3,1176,'A partir de las estimaciones de la @tbl-svyby-pobreza-sexo2, el siguiente código computacional utiliza `svycontrast()` para calcular la proporción de mujeres en pobreza menos la de hombres y obtener el error estándar de esa diferencia.')
whole(c3,1202,'El siguiente código computacional extrae la matriz de varianzas y covarianzas con `vcov()` y conserva sus nombres de fila como una columna para presentarla en la @tbl-vcov-sex-pobreza.')
whole(c3,1227,'El siguiente código computacional calcula el error estándar de la diferencia a partir de la matriz anterior. Para ello, obtiene la raíz cuadrada de la suma de las varianzas de ambas proporciones menos dos veces su covarianza.')
whole(c3,1289,'El error estándar de cada contraste requiere considerar tanto las varianzas de las tasas regionales como sus covarianzas. El siguiente código computacional extrae esta matriz y la organiza en una tabla, conservando los nombres de las regiones.')
edit(c3,1366,'En esta sección se utiliza el paquete `ggplot2` para construir los gráficos. El siguiente código computacional carga `ggplot2` para construir los gráficos de esta sección.','El siguiente código computacional carga `ggplot2`, que se utilizará para representar estas estimaciones.')
edit(c3,1593,'En `R`, las librerías `sf` y `tmap` permiten cargar, manipular y visualizar esta información geográfica de manera integrada con los resultados obtenidos a partir de la encuesta.','El siguiente código computacional carga las librerías `sf` y `tmap` para trabajar con la información geográfica y vincularla con los resultados de la encuesta.')
edit(c3,1593,' El siguiente código computacional carga las herramientas cartográficas e importa la información geográfica de las regiones.','')
edit(c3,1614,'Con el *shapefile* cargado, se puede generar un mapa de las regiones usando `tm_shape()` y `tm_polygons()`, como se muestra en la @fig-mapa-regiones: El siguiente código computacional crea el mapa.','Con el *shapefile* cargado, el siguiente código computacional genera el mapa de la @fig-mapa-regiones mediante `tm_shape()` y `tm_polygons()`.')
edit(c3,1621,'Para ello, el objeto','En el siguiente código computacional, el objeto')
edit(c3,1621,' El siguiente código computacional prepara las estimaciones de pobreza masculina por región para su representación cartográfica.','')

edit(c4,173,'Si el objetivo es estimar el total poblacional del ingreso per cápita, pero desagregado por sexo, se puede utilizar','Para estimar el total poblacional del ingreso per cápita por sexo, el siguiente código computacional utiliza')
edit(c4,173,' El siguiente código computacional estima los totales de ingreso por sexo e incorpora el total general.','')
whole(c4,292,'El mismo procedimiento permite estimar medias por subgrupos. El siguiente código computacional calcula el gasto medio por zona y sus medidas de precisión, cuyos resultados se presentan en la @tbl-media-gasto-zona.')
edit(c4,318,'Asimismo, es posible realizar una estimación combinada por zona y región, presentada en la @tbl-media-gasto-zona-reg: El siguiente código computacional estima el gasto medio para las combinaciones de zona y región.','Para examinar diferencias con mayor detalle, el siguiente código computacional estima el gasto medio por zona y región, como se presenta en la @tbl-media-gasto-zona-reg.')
edit(c4,492,'La estimación puede desagregarse por zona de residencia mediante `group_by(Zone)`.','El siguiente código computacional desagrega esta estimación por zona de residencia mediante `group_by(Zone)`.')
edit(c4,492,' El siguiente código computacional estima el índice de envejecimiento por zona.','')
whole(c4,566,'El siguiente código computacional estima la razón de dependencia demográfica por zona de residencia. `group_by(Zone)` define los dominios dentro del diseño completo, conservando sus estratos, UPM y factores de expansión, sin construir diseños nuevos a partir de archivos separados.')
whole(c4,647,'El siguiente código computacional estima la razón de dependencia económica por zona mediante `group_by(Zone)`, manteniendo las características del diseño y el dominio de edad y condición de actividad definidos previamente.')
whole(c4,943,'El siguiente código computacional utiliza `svyvar()` del paquete `survey` para estimar la matriz de varianzas y covarianzas del ingreso y el gasto per cápita, incorporando el diseño muestral. Luego organiza los resultados con los nombres de las variables para presentarlos en la @tbl-covarianza. Esta matriz también permite calcular la correlación entre ambas variables.')
edit(c4,980,'Otra opción es utilizar la función `svycor()` del paquete `jtools` [@jtools2026] para estimar directamente la correlación: El siguiente código computacional obtiene la correlación entre ingreso y gasto mediante `svycor()`.','El siguiente código computacional ilustra otra opción: estimar directamente la correlación entre ingreso y gasto con `svycor()` del paquete `jtools` [@jtools2026].')
edit(c4,1026,'El siguiente código crea primero','El siguiente código computacional crea primero')
edit(c4,1026,'Para presentar los resultados de la prueba en una tabla, el siguiente código computacional reúne','Finalmente, se reúnen')
edit(c4,1091,'Para esto, es necesario crear un objeto con las medias de los ingresos desagregados por región, como se presenta en la @tbl-prom-region: El siguiente código computacional estima las medias regionales de ingreso y conserva sus covarianzas. El siguiente código computacional conserva las estimaciones por región en un objeto tabular que se utiliza para presentar los resultados.','El siguiente código computacional estima las medias regionales de ingreso, conserva sus covarianzas y organiza los resultados para presentarlos en la @tbl-prom-region.')
edit(c4,1122,'El siguiente código computacional estima la diferencia entre los ingresos medios de Norte y Sur mediante `svycontrast()`. Para presentar el contraste Norte menos Sur con su error estándar e intervalo de confianza, el siguiente código computacional reúne esas medidas en una tabla.','El siguiente código computacional estima la diferencia entre los ingresos medios de Norte y Sur mediante `svycontrast()` y reúne el contraste, su error estándar y su intervalo de confianza para presentarlos en la tabla.')
edit(c4,1155,'Si se consideran únicamente los ingresos medios estimados de las regiones Norte y Sur, su diferencia es: El siguiente código computacional calcula directamente la diferencia Norte menos Sur a partir de las medias estimadas.','El siguiente código computacional inicia este cálculo directo restando el ingreso medio estimado de Sur al de Norte.')
whole(c4,1201,'Para evitar inconsistencias por redondeo, el siguiente código computacional calcula el error estándar de la diferencia Norte menos Sur directamente a partir de la matriz estimada de varianzas y covarianzas.')
edit(c4,1223,'A continuación, se muestra la implementación de los contrastes en `R`, cuyos resultados se presentan en la @tbl-contraste-regiones. El siguiente código computacional organiza las diferencias regionales estimadas, sus errores estándar y sus intervalos de confianza para presentarlos conjuntamente.','El siguiente código computacional estima estos contrastes y organiza las diferencias regionales, sus errores estándar y sus intervalos de confianza para presentarlos en la @tbl-contraste-regiones.')
whole(c4,1259,'También pueden construirse contrastes para comparar el ingreso per cápita según el sexo de la persona jefa del hogar. El siguiente código computacional utiliza `survey_design_heads` para estimar la media de cada grupo y organizar las estimaciones y sus medidas de precisión, presentadas en la @tbl-prom-sexo.')
edit(c4,1291,'A continuación, utilizando la función `svycontrast()`, se obtiene la estimación del contraste, cuyos resultados se presentan en la @tbl-contraste-sexo. El siguiente código computacional organiza la diferencia de medias entre mujeres y hombres junto con su error estándar e intervalo de confianza.','El siguiente código computacional estima esta diferencia mediante `svycontrast()` y organiza su error estándar e intervalo de confianza para presentarlos en la @tbl-contraste-sexo.')
edit(c4,1327,'A continuación, se presentan los códigos computacionales utilizados para realizar este análisis, cuyos resultados se muestran en la @tbl-razon-ingreso-gasto-sexo: El siguiente código computacional prepara las razones ingreso/gasto por sexo y sus medidas de precisión para presentarlas en una tabla.','El siguiente código computacional estima las razones ingreso/gasto por sexo y organiza sus medidas de precisión para presentarlas en la @tbl-razon-ingreso-gasto-sexo.')
whole(c4,1359,'El siguiente código computacional utiliza `svycontrast()` para comparar las razones ingreso/gasto de los hogares con jefatura femenina y masculina, incorporando el diseño muestral. La diferencia, su error estándar y su intervalo de confianza se presentan en la @tbl-contraste-razon-sexo.')

edit(c5,138,'El proceso inicia con la carga de las librerías, los datos y la definición del diseño de muestreo: El siguiente código computacional','El siguiente código computacional')
edit(c5,194,'Para ajustar modelos incorporando los factores de expansión se usa la función `svyglm` de la librería `survey`, que permite estimar modelos lineales incorporando explícitamente las características del diseño muestral.','El siguiente código computacional ajusta un modelo lineal mediante `svyglm()` del paquete `survey`, incorporando los factores de expansión y las demás características del diseño muestral.')
edit(c5,194,' El siguiente código computacional ajusta el modelo de regresión mediante `svyglm()`, incorporando el diseño muestral.','')
whole(c5,235,'El siguiente código computacional obtiene los componentes necesarios para calcular el coeficiente de determinación $R^{2}$. Para estimar la suma total ponderada de cuadrados ($\\widehat{SST}$), ajusta primero un modelo nulo que incluye únicamente el intercepto.')
edit(c5,411,'Una vez obtenidos los valores de la medida DFBETA para cada observación y coeficiente del modelo, se calcula','A partir de los valores DFBETA de cada observación y coeficiente del modelo, el siguiente código computacional calcula')
edit(c5,411,' El siguiente código computacional organiza los valores DfBetas e identifica las observaciones que superan el umbral de influencia.','')
whole(c5,548,'El siguiente código computacional prepara la tabla de inferencia e incorpora los límites producidos por `confint()`, de modo que se presenten tanto las pruebas $t$ como los intervalos de confianza de los coeficientes.')
whole(c5,585,'El siguiente código computacional utiliza `broom::tidy()` [@broom2026] para organizar los coeficientes del modelo, sus errores estándar y las pruebas correspondientes en una tabla ordenada.')
edit(c5,634,'La matriz estimada de varianzas y covarianzas se presenta en la @tbl-vcov-modelo, utilizando las etiquetas Beta 0 a Beta 8 en el mismo orden de los coeficientes descrito anteriormente: El siguiente código computacional extrae y organiza la matriz de varianzas y covarianzas de los coeficientes.','El siguiente código computacional extrae esta matriz y la organiza con las etiquetas Beta 0 a Beta 8, siguiendo el orden de los coeficientes descrito anteriormente, para presentarla en la @tbl-vcov-modelo.')
whole(c5,676,'El siguiente código computacional utiliza `predict(fit_svy, type = "link")` para estimar el valor medio en la escala del predictor lineal, es decir, mediante la combinación lineal de las covariables y los coeficientes del modelo [@Lumley2026]. Después obtiene los intervalos de confianza con `confint()`.')

edit(c6,117,'Siguiendo con la encuesta de ejemplo, y con el fin de analizar los factores asociados a la condición de pobreza, se ajusta','Para analizar los factores asociados a la condición de pobreza en la encuesta de ejemplo, el siguiente código computacional ajusta')
edit(c6,117,' El siguiente código computacional selecciona una observación por hogar y ajusta el modelo logístico de pobreza.','')
edit(c6,190,'El siguiente código computacional ajusta el modelo logístico que incorpora la interacción entre sexo y tamaño del hogar. Para comparar los coeficientes del modelo con interacción, el siguiente código computacional reúne las estimaciones, los errores estándar, los intervalos de confianza y sus exponenciales.','El siguiente código computacional ajusta este modelo y reúne los coeficientes, sus errores estándar, los intervalos de confianza y sus exponenciales para facilitar la comparación.')
whole(c6,363,'Como referencia inicial, el siguiente código computacional estima la distribución por estado de empleo entre las personas de 15 años o más. Los resultados se presentan en la @tbl-prop-empleo-15.')
edit(c6,558,'El siguiente código ajusta','El siguiente código computacional ajusta')
edit(c6,558,'Los coeficientes estimados se presentan en la @tbl-gamma-coeficientes: Para presentar los resultados del modelo Gamma, el siguiente código computacional reúne los coeficientes y sus medidas de precisión, y calcula el factor multiplicativo correspondiente a cada coeficiente.','Finalmente, se reúnen los coeficientes, sus medidas de precisión y los factores multiplicativos correspondientes para presentarlos en la @tbl-gamma-coeficientes.')

edit(c7,84,'Para incorporar gradualmente la estructura jerárquica de los datos al proceso de modelación, se ajusta inicialmente','Para incorporar gradualmente la estructura jerárquica de los datos, el siguiente código computacional ajusta')
edit(c7,84,' El siguiente código computacional estima una pendiente común a partir de todos los datos y un intercepto para cada estrato; estos coeficientes se utilizarán para trazar las rectas de regresión.',' Los coeficientes se utilizarán para trazar las rectas de regresión.')
edit(c7,164,'Bajo este enfoque, cada estrato posee su propia recta de regresión, con interceptos y pendientes estimados de manera independiente. El siguiente código computacional obtiene interceptos y pendientes mediante regresiones separadas por estrato.','El siguiente código computacional ajusta una regresión independiente para cada estrato, de modo que cada uno tenga su propio intercepto y pendiente.')
edit(c7,357,'De acuerdo con @performance2026, a partir de los componentes de varianza estimados en el modelo nulo, la correlación intraclase se calcula mediante la función `icc()` del paquete `performance`.','El siguiente código computacional calcula la correlación intraclase a partir de los componentes de varianza del modelo nulo mediante `icc()` del paquete `performance` [@performance2026].')
edit(c7,357,' El siguiente código computacional calcula y organiza la correlación intraclase del modelo nulo.','')
whole(c7,436,'Para visualizar los resultados en la submuestra de tres estratos definida anteriormente, el siguiente código computacional selecciona los coeficientes correspondientes del modelo ajustado.')
whole(c7,562,'El siguiente código computacional selecciona los coeficientes del modelo con pendiente aleatoria correspondientes a los tres estratos de la submuestra utilizada en las ilustraciones.')
whole(c7,871,'Para visualizar las probabilidades estimadas por el modelo con pendiente aleatoria, el siguiente código computacional construye una secuencia de valores de gasto dentro de cada estrato y obtiene las predicciones correspondientes.')

whole(a1,90,'Los ejemplos de procesamiento y visualización utilizan la base `BigCity` del paquete `TeachingSampling`. El siguiente código computacional la carga y crea una copia para trabajar con ella.')
whole(a1,99,'El objeto `bigcity_data` contiene una copia de `BigCity`. El siguiente código computacional utiliza `head()` para mostrar sus primeras filas y obtener una impresión rápida de su estructura.')
whole(a1,105,'Una primera revisión consiste en conocer las dimensiones de la base. El siguiente código computacional utiliza `nrow()` para obtener el número de registros y `ncol()` para obtener el número de variables.')
whole(a1,115,'El siguiente código computacional consulta ambas dimensiones mediante `dim()`, que devuelve un vector con el número de filas en la primera posición y el número de columnas en la segunda.')
whole(a1,127,'Para identificar las variables disponibles, el siguiente código computacional muestra sus nombres mediante `names()`.')
whole(a1,168,'El siguiente código computacional filtra la base por condición de pobreza y guarda en `nonpoor_data` los registros cuya variable `Poverty` toma el valor `"NotPoor"`, correspondiente a las personas no pobres.')
edit(a1,190,'Para ilustrar la selección de columnas, se retoma','Para ilustrar esta operación, el siguiente código computacional retoma')
edit(a1,190,' El siguiente código computacional conserva las columnas seleccionadas en el objeto de trabajo.','')
whole(a1,199,'`select()` también permite excluir variables anteponiendo el signo menos (`-`) a sus nombres. El siguiente código computacional crea `compact_data` a partir de `working_data`, omitiendo las columnas de identificación `HHID` y `PersonID`.')
edit(a1,320,'En este caso, se obtiene','El siguiente código computacional obtiene')
edit(a1,320,' El siguiente código computacional calcula los cuantiles del ingreso y el rango decílico.','')
edit(a1,334,'Con `summarise()` también es posible calcular medidas de dispersión, tales como','El siguiente código computacional utiliza `summarise()` para calcular medidas de dispersión:')
edit(a1,334,' El siguiente código computacional calcula las medidas de dispersión del ingreso descritas.','')
whole(a1,373,'La misma lógica de agrupación y conteo permite conocer cuántos registros corresponden a cada sexo. El siguiente código computacional agrupa la base por `Sex` y cuenta las observaciones de cada categoría.')
whole(a1,394,'Además de los conteos, pueden calcularse medidas resumen por grupo. El siguiente código computacional agrupa la base por `Region` y utiliza `summarise()` para obtener el número de registros y el ingreso medio de cada región.')
whole(a1,406,'El siguiente código computacional aplica el mismo procedimiento por sexo: agrupa la base por `Sex` y calcula el promedio de `Income` para comparar el ingreso medio de cada categoría.')

edit(a3,71,'Primero, se cargan los paquetes y se estima','El siguiente código computacional carga los paquetes y estima')
edit(a3,71,' El siguiente código computacional prepara el diseño muestral y los dominios utilizados para la tasa de desocupación y los ejercicios de imputación.','')
edit(a3,104,'También se calcula el promedio de ingresos en la muestra: El siguiente código computacional calcula la media del ingreso en la muestra.','Como referencia para los ejercicios posteriores, el siguiente código computacional calcula también la media del ingreso en la muestra.')
whole(a3,554,'Una vez realizada la imputación, el siguiente código computacional compara la media y la desviación estándar del ingreso original con las del ingreso completado.')
edit(a3,581,'El mismo ejercicio se realiza por sexo: El siguiente código computacional compara por sexo los resúmenes del ingreso original y del completado mediante imputación.','El siguiente código computacional extiende la comparación de estos resúmenes a los grupos definidos por sexo.')
whole(a3,623,'El siguiente código computacional ajusta un modelo de regresión lineal múltiple para imputar el ingreso, utilizando la zona, el sexo y el gasto como covariables.')
whole(a3,636,'Una vez ajustado el modelo, el siguiente código computacional obtiene las predicciones y las utiliza para completar los ingresos faltantes.')
edit(a3,660,'El mismo ejercicio se realiza por zona: El siguiente código computacional compara por zona los resúmenes del ingreso original y del completado por regresión.','El siguiente código computacional compara por zona los resúmenes del ingreso original y del completado por regresión.')
edit(a3,741,'El mismo ejercicio se realiza por zona: El siguiente código computacional compara por zona los resúmenes del ingreso original y del completado con donantes.','El siguiente código computacional compara por zona los resúmenes del ingreso original y del completado con donantes.')
whole(a3,804,'Con el modelo ajustado, el siguiente código computacional predice los ingresos de las observaciones con y sin datos faltantes. Para cada receptor, identifica al donante con la predicción más cercana y utiliza su ingreso observado para completar el valor faltante.')
whole(a3,825,'Como en los ejemplos anteriores, el siguiente código computacional compara la media y la desviación estándar del ingreso original con las del ingreso completado, en este caso mediante donantes seleccionados por la proximidad de sus predicciones.')
edit(a3,951,'Una vez ejecutado el código, se muestran los ingresos originales y algunos de los valores imputados: El siguiente código computacional muestra los ingresos originales junto con algunos de los valores imputados.','El siguiente código computacional permite revisar los ingresos originales junto con algunos de los valores imputados.')
whole(a3,983,'Con los conjuntos de datos completados, el siguiente código computacional define el diseño muestral que se utilizará para estimar los parámetros de interés.')
whole(a3,996,'A partir de este diseño, el siguiente código computacional estima la media del ingreso y su varianza en cada conjunto de datos completado.')
whole(a3,1021,'El siguiente código computacional combina las medias estimadas y sus varianzas mediante las reglas de imputación múltiple descritas anteriormente.')
edit(a3,1044,'Para estimarla, se aplica el mismo procedimiento utilizado para la media, cambiando el parámetro de interés: El siguiente código computacional reorganiza las estimaciones de la varianza del ingreso y sus medidas de incertidumbre para combinarlas por imputación.','Se sigue el mismo procedimiento utilizado para la media: el siguiente código computacional reorganiza las estimaciones de la varianza del ingreso y sus medidas de incertidumbre para combinarlas por imputación.')
whole(a3,1063,'Por último, el siguiente código computacional combina las estimaciones de la varianza del ingreso y su incertidumbre mediante las expresiones anteriores.')

# Integrate figure introductions only within individual prose lines.
for file, text in list(texts.items()):
    lines = text.splitlines(keepends=True)
    in_fence = False
    for i,line in enumerate(lines):
        if line.startswith('```'):
            in_fence = not in_fence
        if in_fence:
            continue
        pattern = r' El siguiente código computacional construye (?:la (@fig-[\w-]+)|el gráfico|la pirámide)(?: a partir de los datos y las estimaciones descritos| para comparar las distribuciones del ingreso antes y después de la selección)?\.'
        match = re.search(pattern,line)
        if not match:
            continue
        ref = match[1]
        before = line[:match.start()]
        if not ref:
            refs = re.findall(r'@fig-[\w-]+',before)
            assert refs, (file,i)
            ref = refs[-1]
        if ref in before:
            # Retain a single reference and connect it explicitly to the code.
            before = before.replace(ref, ref + ', obtenida con el siguiente código computacional,', 1)
            before = before.replace('computacional,.','computacional.').replace('computacional,:','computacional.').replace('computacional,;','computacional;')
            before = before.rstrip(':')
            if not before.endswith(('.', ';')):
                before += '.'
            lines[i] = before + line[match.end():]
        else:
            # The figure has not yet been referenced in this paragraph.
            lines[i] = before.rstrip(':') + ' El siguiente código computacional genera la ' + ref + '.' + line[match.end():]
    texts[file] = ''.join(lines)

def blocks(text):
    return re.findall(r'^```[^\n]*\n.*?^```[^\S\n]*$',text,re.M|re.S)

for file,after in texts.items():
    before=snapshot[file]
    assert blocks(before)==blocks(after), ('Code changed',file)
    assert re.findall(r'`r [^`]*`',before)==re.findall(r'`r [^`]*`',after), ('Inline R changed',file)
    if before!=after:
        Path(file).write_bytes(after.encode('utf8'))
        changes.append((file,sum(a!=b for a,b in zip(before.splitlines(),after.splitlines()))))
print(json.dumps(changes,ensure_ascii=False,indent=2))
