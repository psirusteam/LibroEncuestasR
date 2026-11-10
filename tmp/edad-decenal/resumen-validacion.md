# Agrupación decenal — 6 de noviembre de 2026

- `sample.rds`: 2.605 personas y 20 variables. Solo se modifica `CatAge`.
- Diez factores ordenados: 0-9, 10-19, 20-29, 30-39, 40-49, 50-59, 60-69, 70-79, 80-89 y 90-99.
- Se preservan `Age`, el diseño muestral, los pesos y los valores faltantes.
- Tamaños por edad: 10 filas; tamaños por edad y sexo: 20 filas; pobreza: 10 filas; desocupación femenina: 9 filas (fuerza de trabajo de 15 años o más).
- En desocupación, 10-19 representa únicamente el dominio de 15-19; no se incorpora a menores de 15.
- Pobreza y desocupación usan la media de la indicadora, evitando perder grupos sin eventos. Los intervalos `xlogit` transforman la media ponderada; los límites no calculables en tasas 0/1 se presentan como NA.
- Se preservan las definiciones de envejecimiento, dependencia y población en edad de trabajar mediante la edad individual.
- Pruebas: comparación de las otras 19 columnas con copia previa; asignación de cada edad; sumas ponderadas; conteos; capas de la pirámide; tasas frente a cocientes independientes; índices y sus varianzas.
- Copia previa: `tmp/edad-decenal/sample-anterior.rds`.
