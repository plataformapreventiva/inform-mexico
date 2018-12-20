#!/usr/bin/env Rscript
options(warn=-1)

source("models/inform_index/aux.R")
library(optparse)
library(dbplyr)
library(dplyr)
library(DBI)
library(lubridate)
library(yaml)
library(tidyr)
library(mice)
library(psych)
library(car)
library(rlist)
library(classInt)
library(stringr)
library(scales)






option_list = list(
  make_option(c("--current_date"), type="character", default="",
              help="current date", metavar="character"),
  make_option(c("--data_date"), type="character", default="",
              help="data date", metavar="character"),
  make_option(c("--database"), type="character", default="",
              help="database name", metavar="character"),
  make_option(c("--user"), type="character", default="",
              help="database user", metavar="character"),
  make_option(c("--password"), type="character", default="",
              help="password for datbase user", metavar="character"),
  make_option(c("--host"), type="character", default="",
              help="database host name", metavar="character"),
  make_option(c("--pipeline"), type="character", default="",
              help="model pipeline", metavar="character")

)

opt_parser <- OptionParser(option_list=option_list)

opt <- tryCatch(
  {
    parse_args(opt_parser)
  },
  error=function(cond) {
    message("Error: Provide database connection arguments appropriately.")
    message(cond)
    print_help(opt_parser)
    return(NA)
  },
  warning=function(cond) {
    message("Warning:")
    message(cond)
    return(NULL)
  },
  finally={
    message("Finished attempting to parse arguments.")
  }
)

if(length(opt) > 1){

  if (opt$database=="" | opt$user=="" |
      opt$password=="" | opt$host=="" ){
    print_help(opt_parser)
    stop("Database connection arguments are not supplied.n", call.=FALSE)
  }else{
    PGDATABASE <- opt$database
    POSTGRES_PASSWORD <- opt$password
    POSTGRES_USER <- opt$user
    PGHOST <- opt$host
    PGPORT <- "5432"
  }

  con <- DBI::dbConnect(RPostgres::Postgres(),
                        host = PGHOST,
                        port = PGPORT,
                        dbname = PGDATABASE,
                        user = POSTGRES_USER,
                        password = POSTGRES_PASSWORD
  )


  print('Pulling datasets')

  data <- tbl(con, dbplyr::in_schema('features','inform_variables_municipios'))  %>%
    select(-c(actualizacion_sedesol,data_date,media_salario_m,media_salario_h,pobreza_porcentaje,inf_publ)) %>%
    collect()
  estructura <- read_yaml("data/estructura_indice.yaml")

  #----------------------------------------------------------------------------------------

  # LIMPIEZA CATEGÓRICAS

  # Categóricas -> Numéricas
  # Clasifica las categóricas por tipo
  # Como ya están categorizadas las volvemos numéricas

  categoricas_5 <- get_var_from_type(estructura,"categorica_5")
  data[,categoricas_5]  <- data[,categoricas_5] %>%
    mutate_all(funs(car::recode(var = .,
                           recodes = "'Muy bajo'=0;
                           'Bajo'=25;
                           'Medio'=50;'Alto'=75;
                           'Muy alto'=100")))

  categoricas_tsunami <- get_var_from_type(estructura,"categorica_tsunami")
  data[,categoricas_tsunami]  <- data[,categoricas_tsunami] %>%
    mutate_all(funs(recode(var = .,
                           recodes = "'Sin peligro'=0;
                           'Muy alto'=100")))

  #Existencia de unidad de protección civil
  #{0-NA|1-si|2-no|3-en proceso de integracion|8-info no disponible|9-no se sabe}
  categoricas_nd_spnn1 <- get_var_from_type(estructura,"categorica_nd_spnn1")
  data[,categoricas_nd_spnn1]  <- data[,categoricas_nd_spnn1] %>%
    mutate_all(funs(recode(var = .,
                         recodes = "0=0;
                        1=0;2=100;
                         3=25;8=50;
                         9=50")))

  #Existencia de Atlas de Riesgo
  #Participacion ciudadana
  #{0-NA|1-si|2-no|8-info no disponible|9-no se sabe}
  categoricas_nd_nsnn4 <- get_var_from_type(estructura,"categorica_nd_nsnn4")
  data[,categoricas_nd_nsnn4]  <- data[,categoricas_nd_nsnn4] %>%
    mutate_all(funs(recode(var = .,
                           recodes = "0=0;
                         1=0;2=100;
                         8=50;9=50")))

  # Gobernabilidad
  # Existencia de órganos de participación ciudadana
  #{0-NA|1-si}
  categoricas_nd_nsnn1 <- get_var_from_type(estructura,"categorica_nd_nsnn1")
  data[,categoricas_nd_nsnn1]  <- data[,categoricas_nd_nsnn1] %>%
    mutate_all(funs(recode(var = .,
                           recodes = "0=100;1=0")))

  # Cobro predial
  # {0-NA|1-gobierno municipal|2-gobierno de la Entidad Federativa|3-No se cobra|9-No se sabe}
  categoricas_aut_cobr <- get_var_from_type(estructura,"categorica_aut_cobr")
  data[,categoricas_aut_cobr]  <- data[,categoricas_aut_cobr] %>%
    mutate_all(funs(recode(var = .,
                           recodes = "0=0;
                        1=0;2=25;3=
                       3=100;9=50")))

  # Mecanismos de transferencia
  # {(1+1+1)/3}
  categoricas_mec_tran <- get_var_from_type(estructura,"categorica_mec_tran")
  data[,categoricas_mec_tran]  <- data[,categoricas_mec_tran] %>%
    mutate_all(funs(recode(var = .,
                           recodes = "0=100;
                        1/3=75;2/3=50;1=0")))

  # índice sist político estable
  # ranking 1-32
  categoricas_politico <- get_var_from_type(estructura,"categorica_politico")
  data[,categoricas_politico]  <- data[,categoricas_politico] %>%
    mutate_all(funs(recode(var = .,
                           recodes = "1=0;2=0;3=0;
                                      4=0;5=0;6=0;
                                      7=25;8=25;9=25;
                                      10=25;11=25;12=25;
                                      13=50;14=50;15=50;
                                      16=50;17=50;18=50;
                                      19=50;20=75;21=75;
                                      22=75;23=75;24=75;
                                      25=75;26=75;27=100;
                                      28=100;29=100;30=100;
                                         31=100;32=100")))

  #----------------------------------------------------------------------------------------

  # LIMPIEZA NUMÉRICAS
  # Define las variables numéricas (Obtener de yaml)
  numericas <- get_var_from_type(estructura,"^numerica$")
  data[,numericas] <- lapply(data[, numericas], as.numeric)

  # Queremos que inform siempre sea más es peor
  # Acá define las variables donde más sea mejor
  mas_mejor <- get_var_from_type(estructura,"^mas_mejor$")
  data[,mas_mejor] <- data[,mas_mejor]*-1

  # Crear cortes
  # kmeans (por ahora)
  lapply(numericas, get_cuts, data=data)

  amenazas <- get_var_from_name(estructura, "Amenazas")
  vulnerabilidad <- get_var_from_name(estructura, "Vulnerabilidad")
  capacidades <- get_var_from_name(estructura, "Capacidades")
  data <- to_numeric(data, amenazas)
  data <- to_numeric(data, vulnerabilidad)
  data <- to_numeric(data, capacidades)

  inform_input <- mice(data = data, m=5, method = "pmm", maxit = 10, seed = 500)

  i1 <- mice::complete(inform_input,1)
  #i2 <- complete(inform_input,2)
  #i3 <- complete(inform_input,3)
  #i4 <- complete(inform_input,4)
  #i5 <- complete(inform_input,5)

  #----------------------------------------------------------------------------------------

  # AGREGADO DE DIMENSIÓN
  dimensiones <- names(estructura$Inform$Dimensión)
  df <- NULL
  subdimension_l <- list()
  subsubdimension_l <- list()

  # Media aritmética entre subdimensiones
  for (dimension in dimensiones) {
    subdimensiones <- estructura$Inform$Dimensión[[eval(dimension)]] %>%
      purrr::flatten() %>% names()
    subdimension_l <- append(subdimension_l, subdimensiones)
    for (subdimension in subdimensiones) {
      Subsubdimensiones <- estructura$Inform$Dimensión[[
        eval(dimension)]]$Subdimensión[[eval(subdimension)]] %>%
        purrr::flatten() %>% names()
      subsubdimension_l <- append(subsubdimension_l, Subsubdimensiones)
      for (Subsubdimensión in Subsubdimensiones) {
        variables <- get_var_from_name(estructura,Subsubdimensión)
        pca_subsub <- i1[variables] %>% prcomp()
        i1[Subsubdimensión] <- pca_subsub$x[,1] %>%
            scales::rescale(to=c(1,100)) %>%
            as.data.frame()
      }
      print(pca_subsub$sdev^2 / sum(pca_subsub$sdev^2))
      i1[subdimension] <- i1[Subsubdimensiones] %>% as.data.frame() %>%
        rowMeans(na.rm = TRUE)
    }
    i1[dimension] <- i1[subdimensiones] %>% as.data.frame() %>%
      rowMeans(na.rm = TRUE)
  }


  # Media geométrica entre dimensiones
  i1["INFORM"] <-apply(i1[dimensiones], 1,geometric.mean,na.rm=TRUE)

  inform <- i1 %>% dplyr::select(cve_muni, INFORM, dimensiones,
                                 amenazas,capacidades,vulnerabilidad,
                                 unlist(subdimension_l),
                                 unlist(subsubdimension_l))

  inform <- arrange(inform, desc(INFORM)) %>%
            mutate(ranking = 1:nrow(inform),
                   cve_ent = substr(cve_muni, 1, 2))

  #----------------------------------------------------------------------------------------

  # Save model table

  temp <- sapply(colnames(inform),str_replace_all, "[1-9].","")
  colnames(inform) <- sapply(temp,str_replace_all, " +","_")
  colnames(inform) <- sapply(colnames(inform),str_replace_all, "^_","")
  colnames(inform) <-  sapply(colnames(inform),str_to_lower)
  colnames(inform) <- sapply(colnames(inform),str_replace_all, "/","")
  colnames(inform) <- sapply(colnames(inform),iconv, from="UTF-8",to="ASCII//TRANSLIT")

  table_id = DBI::Id(schema = 'models', table = 'inform_index')
  copy_to(con, inform,
          name=in_schema("models",'inform_index_municipios'),
          temporary = FALSE, overwrite = TRUE)
  dbDisconnect(con)

  print(paste0('Features written to: models.',opt$pipeline))
}
