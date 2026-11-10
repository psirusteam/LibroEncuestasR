from pathlib import Path
import json,re

replacements={
'04-Continuas-alternativa':[
('Para realizar la curva de Lorenz en `R` se utiliza la función `svylorenz()` El siguiente código computacional genera la @fig-lorenz.','El siguiente código computacional utiliza `svylorenz()` para estimar la curva de Lorenz representada en la @fig-lorenz.'),
('El paso siguiente consiste en calcular la matriz de varianzas y covarianzas y extraer de ella los elementos correspondientes a las regiones Norte y Sur, los cuales se presentan en la @tbl-vcov-region.','El siguiente código computacional obtiene la matriz de varianzas y covarianzas y la organiza con los nombres de las regiones para presentarla en la @tbl-vcov-region. De ella se extraen los elementos correspondientes a Norte y Sur.'),
(' El siguiente código computacional convierte la matriz de varianzas y covarianzas en una tabla e incorpora los nombres de las regiones.',''),
],
'03-Categoricas-alternativa':[
('utiliza `labor_force_subset` y se agrupa por','utiliza `labor_force_subset` y agrupa las observaciones por'),
('Por ejemplo, es posible estimar la proporción de hombres según zona de residencia y condición de pobreza de manera simultánea.','El siguiente código computacional ilustra esta posibilidad al estimar la composición por condición de pobreza dentro de cada zona de la población masculina.'),
(' El siguiente código computacional estima la composición por condición de pobreza dentro de cada zona de la población masculina.',''),
('En este ejemplo se compara la tasa de desocupación de las mujeres de 15 a 45 años, inclusive, con la de las mayores de 45 años.','El siguiente código computacional compara la tasa de desocupación de las mujeres de 15 a 45 años, inclusive, con la de las mayores de 45 años.'),
(' El siguiente código computacional estima las tasas de desocupación femenina para los grupos de edad definidos.',''),
('Para comparar la distribución de la pobreza entre regiones, se agrupa el diseño por `Region` y por la categoría `poor`. Así, `survey_prop()` estima, dentro de cada región, las proporciones de personas pobres y no pobres. El siguiente código computacional calcula esas proporciones, sus errores estándar y sus intervalos de confianza; los resultados se presentan en la @tbl-svyby-region-pobreza.','Para comparar la distribución de la pobreza entre regiones, el siguiente código computacional agrupa el diseño por `Region` y `poor`. Así, `survey_prop()` estima las proporciones de personas pobres y no pobres dentro de cada región, junto con sus errores estándar e intervalos de confianza. Los resultados se presentan en la @tbl-svyby-region-pobreza.'),
('Este mismo procedimiento puede emplearse para evaluar otras asociaciones entre variables categóricas, como condición de actividad y sexo. El siguiente código computacional aplica la prueba de independencia entre la condición de empleo y el sexo.','El siguiente código computacional aplica el mismo procedimiento para evaluar la asociación entre condición de empleo y sexo.'),
('Otro ejercicio consiste en estimar la tasa de desocupación por región de residencia. Se utiliza `labor_force_subset`, de modo que el denominador es la fuerza de trabajo de cada región. Los resultados se presentan en la @tbl-tasa-desocupacion-region y se expresan en escala de cero a uno. El siguiente código computacional estima las tasas de desocupación regionales y conserva sus covarianzas.','El siguiente código computacional estima las tasas de desocupación por región y conserva sus covarianzas para los contrastes posteriores. Se utiliza `labor_force_subset`, de modo que el denominador es la fuerza de trabajo de cada región. Los resultados se presentan en la @tbl-tasa-desocupacion-region y se expresan en escala de cero a uno.'),
('La @fig-mapa-pobreza-hombre, obtenida con el siguiente código computacional, presenta esta distribución regional; sus colores deben interpretarse según los intervalos indicados en la leyenda.','El siguiente código computacional representa esta distribución regional en la @fig-mapa-pobreza-hombre; sus colores deben interpretarse según los intervalos indicados en la leyenda.'),
('Como ejemplo, se estima la proporción de personas en condición de pobreza entre las mujeres rurales de 15 a 29 años de cada región, incorporando los factores de expansión, los estratos y las UPM del diseño muestral. El siguiente código computacional estima la proporción de pobreza entre las mujeres rurales jóvenes de cada región y resume su precisión.','El siguiente código computacional ilustra esta situación al estimar la proporción de pobreza entre las mujeres rurales de 15 a 29 años de cada región y resumir su precisión, incorporando los factores de expansión, los estratos y las UPM del diseño muestral.'),
],
'05-Regresion':[
('En particular, para evaluar la homocedasticidad respecto de las covariables incluidas en el modelo, se construyen gráficos de residuos frente a cada una de ellas y se combinan con `patchwork`. El siguiente código computacional genera la @fig-residuales-covariables.','El siguiente código computacional construye gráficos de residuos frente a las covariables del modelo y los combina con `patchwork` en la @fig-residuales-covariables.'),
],
'06-GLM':[
('Para visualizar la distribución de los coeficientes se emplea `ggstance` para la geometría horizontal de los intervalos [@ggstance2024], junto con `plot_summs()` del paquete `jtools` [@jtools2026]. El siguiente código computacional genera la @fig-logistica-base.','El siguiente código computacional genera la @fig-logistica-base mediante `plot_summs()` del paquete `jtools` [@jtools2026] y las geometrías horizontales de `ggstance` [@ggstance2024], para visualizar los coeficientes y sus intervalos.'),
],
}
for name,pairs in replacements.items():
 p=Path('chapters')/(name+'.qmd');s=p.read_text(encoding='utf8')
 for old,new in pairs:
  assert old in s,(name,old)
  s=s.replace(old,new,1)
 p.write_bytes(s.encode('utf8'))

# Make the comparison itself introduce the code in the imputation examples.
p=Path('chapters/A3-Imputacion.qmd');s=p.read_text(encoding='utf8')
lines=s.splitlines(keepends=True)
for i,line in enumerate(lines):
 m=re.match(r'La (@fig-[\w-]+), obtenida con el siguiente código computacional, (compara|muestra) ',line)
 if not m:continue
 rest=line[m.end():]
 # Locate the end of the sentence without splitting inline R expressions.
 inside=False;end=None
 for j,ch in enumerate(rest):
  if ch=='`':inside=not inside
  if ch=='.' and not inside and (j+1==len(rest) or rest[j+1].isspace()):
   end=j;break
 assert end is not None
 lines[i]='El siguiente código computacional '+m[2]+' '+rest[:end]+' ('+m[1]+')'+rest[end:]
p.write_bytes(''.join(lines).encode('utf8'))

snapshot=json.loads(Path('tmp/redundancias-antes.json').read_text(encoding='utf8'))
count=0;changed=[]
for name,before in snapshot.items():
 after=Path(name).read_text(encoding='utf8')
 getblocks=lambda t:re.findall(r'^```[^\n]*\n.*?^```[^\S\n]*$',t,re.M|re.S)
 assert getblocks(before)==getblocks(after),('Code altered',name)
 assert re.findall(r'`r [^`]*`',before)==re.findall(r'`r [^`]*`',after),('Inline altered',name)
 assert set(re.findall(r'@[\w-]+',before))==set(re.findall(r'@[\w-]+',after)),('References altered',name)
 if before!=after:
  n=sum(a!=b for a,b in zip(before.splitlines(),after.splitlines()))
  count+=n;changed.append((name,n))
print('Verified: all code blocks, inline R, and reference targets preserved.')
print('Revised paragraphs:',count)
print(json.dumps(changed,ensure_ascii=False,indent=2))
