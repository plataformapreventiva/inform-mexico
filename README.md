# INFORM México

## Introducción

Index For Risk Management (INFORM) retoma la iniciativa y metodología internacional con el objetivo de asignar de forma objetiva los recursos y coordinar las acciones del sistema de protección social enfocadas en anticipar, mitigar y prepararse para emergencias humanitarias. Es un índice a nivel estatal y municipal que prevé tres dimensiones: Amenazas y Exposición que considera aspectos de exposición física y vulnerabilidad física; Vulnerabilidad, representando la fragilidad del sistema socioeconómico y Capacidades de Respuesta, que mide la falta de capacidades para enfrentar y recuperarse de un desastre. De esta forma, el modelo involucra la interacción de dos fuerzas principales: el efecto de contrapeso de la magnitud de peligro y exposición en un lado, y la falta de capacidad de respuesta que genera vulnerabilidad, por otro. 

## Avances
* Integración, limpieza y transformación de variables.
* Índice de riesgo municipal haciendo media aritmética entre subdimensiones (tomando la componente principal de las variables que la componen) y posteriormente media geométrica entre dimensiones.
* Índice de riesgo estatal haciendo media aritmética de los valores municipales.

## Estructura
* eda: directorio que contiene gráficas de análisis exploratorio.
* data: directorio que contiene archivos de texto utilizados en el análisis.
    - estructura_indice.yaml 
    - inform_variables_municipios.csv
* models: directorio que corre el 'data pipeline' del repositorio de politica_preventiva.
* notebooks: directorio que contiene código que implementa algunos métodos planteados.
    - pruebas_input_agg.R script con comparación de iteraciones de imputación de datos faltantes.


## Requisitos
* R

Paquetes:

* tidyverse
* lubridate
* stringr
* mapview
* RColorBrewer
* dbrsocial
* dplyr
* dbplyr
* optparse 
* DBI
* yaml
* tidyr
* mice
* psych
* car
* rlist
* classInt
* stringr
* scales

## Datos

* Dimensión Amenazas y Exposición:
    - Migración Interna
    - Migración Externa
    - Poblaciones Flotantes
    Fuente: Encuesta Intercensal, 2015
    - Inflación (INPC)
    Fuente: INEGI
    - Volatilidad de Precios Agrícolas
    - Anomalía de Producción Agrícola
    Fuente: SEDESOL
    - Grado de Peligro por Inundación
    - Grado de Peligro por Sequía
    - Grado de Peligro por Bajas Temperaturas
    - Grado de Peligro por Ciclones Tropicales
    - Grado de Susceptibilidad de Laderas
    - Grado de Peligro por Sismos
    - Grado de peligro por Tsunami
    Fuente: CENAPRED.
    - Homicidios por cada 100,000 habitantes (Dolosos) - Robo de vehículos
    - Homicidios por cada 100,000 habitantes (Culposos) - Feminicidios
    - Secuestros por cada 100,000 habitantes - Violencia familiar
    Fuente: SEGOB
    - Tasa de Incidencia de Delitos - Violencia escolar
    Fuente: SEP

* Dimensión Falta Capacidades de Respuesta:
    - Existencia de unidad de protección civil
    - Existencia de Atlas de Riesgo
    - Reglamentación en materia de transparencia y acceso a la información
    - Información Pública y de libre acceso
    - Participación Social
    - Viviendas con drenaje
    - Recolección de basura
    - Cobro del impuesto predial
    - Impuesto predial recaudado contra lo programado
    Fuente: Censo Nacional de Gobiernos Municipales y Delegacionales (CNGMD)
    - Capacidad instalada (ministerios públicos)
    - Cantidad de jueces
    Fuente: México Evalúa
    - Índice de Reglamentación Básica Municipal
    Fuente: INAFED
    - Usuarios Comisión Nacional de Electricidad
    Fuente: CFE
    - Cobertura de internet
    - Red nacional de carreteras
    - Distancia a una población de mayor tamaño
    Fuente: INEGI
    - Índice de sistema político estable y funcional
    Fuente: IMCO
    - Densidad de Médicos - Mortalidad Materna
    - Densidad de camas - Mortalidad Infantil
    - Densidad de Hospitales
    Fuente: Secretaría de Salud
    - Complejidad Económica
    - Diversificación Económica
    - Productividad de la tierra
    Fuentes: Atlas de Complejidad Económica.
    - Flexibilidad financiera - Endeudamiento
    - Capacidad de Inversión - Liquidez
    Fuente: SHCP.
    - Índice de progresividad de política pública
    - Índice de cobertura de población total
    Fuente: SEDESOL.

* Dimensión Condición de Vulnerabilidad:
    - Población de adultos mayores
    - Menores entre 0 y 5 años de edad
    - Población adulta joven de 19 a 29 años
    - Relación de dependencia
    - Población que se auto adscribe como indígena
    - Porcentaje de población que sólo habla una lengua indígena
    - Porcentaje de la población que se auto identifica como afrodescendiente
    - Hogares unipersonales
    - Hogares con jefatura femenina
    Fuente: Encuesta Intercensal, 2015
    - Personas con discapacidad
    - Personas con discapacidad física
    - Personas con discapacidad mental
    - Personas con discapacidad sensorial
    - Personas con discapacidad intelectual
    - Población femenina y masculina - Acceso a guarderías
    - Trabajo no remunerado - Participación en el mercado laboral
    - Brecha promedio de tiempo de trabajo no remunerado - Desigualdad salarial
    Fuente: ENIGH.
    - Carencia por acceso a alimentación
    - Rezago Educativo
    - Carencia por acceso a servicios de salud
    - Carencia por acceso a seguridad social
    - Carencia por calidad y espacios de vivienda
    - Carencia por acceso a servicios básicos de vivienda
    - Pobreza por Ingresos
    Fuente: CONEVAL

## Siguientes pasos
  * Conseguir fuentes para las variables:
    - Índice de progresividad de política pública
    - Índice de cobertura de población total
    - Desarrollo administrativo
    - Red nacional de carreteras
    - Distancia a una población de mayor tamaño
    - Mantenimiento y equipamiento de calles y vialidades
    - Embarazo temprano
    - Tormenta Severa
    - Erupciones Volcánicas
    - Violencia institucional
    - Violencia escolar
    - Volatilidad de precios agricolas
    - Anomalia de producción agrícola
    - Desplazamiento Interno Forzado
    - Población en situación de Calle
  * Implementar otros métodos para hacer agregación en el índice municipal.
  * Hacer índice estatal con variables a nivel estatal u otras formas de agregación.

## Referencias
* Documento técnico en:
  https://docs.google.com/document/d/1nNMVhSMGIJ6kArzUA0T_X5ZsvYLmH7gdR2YhLxZz1Us/edit?usp=sharing
