rm(list = ls(all = TRUE))

########################################
## Instalación y preparación de Ambiente
########################################

instalar <- function(paquete) {
  if (!require(paquete,character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)) {
    install.packages(as.character(paquete), repos = "http://cran.us.r-project.org")
    library(paquete, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
  }
}

paquetes <- c("tidyverse", "yaml", "rlist", "car", "classInt",
              "mxmaps", "dbrsocial", "magrittr", "dotenv",
              "tidyverse", "stringr", "corrplot",
              "ggthemes", "psych", "devtools")

lapply(paquetes, instalar);

devtools::install_github("diegovalle/mxmaps")

dotenv::load_dot_env("../.env")
con <- prev_connect()

get_cuts<-function(data, varx){
  # Generación de Cortes
  yy<-as.numeric(unlist(data[,varx] %>% drop_na() ))
  yy<-yy[!is.infinite(yy)]
  ## Se revisa orientación: ¿más es mejor o menos es mejor?
  classes<-classIntervals(var=yy, n=5, style="kmeans") ## Se encuentran los puntos de corte
  cutoffs<-classes$brks  
  yy<-as.numeric(unlist(data[,varx])) ## No se tiran na's (data ya imputado)
  data[,varx] <<- cut(x=yy, include.lowest = T, breaks=cutoffs, labels=c(0,25,50,75,100))
  #data[,paste(varx,"_kmeans", sep="")] <<- cut(x=yy, include.lowest = T, breaks=cutoffs, labels=c(0,25,50,75,100))
  data[[eval(varx)]] <- as.numeric(as.character(data[[eval(varx)]]))
}

get_var_from_type <- function(estructura, pattern){
  # Obtener variable del yaml con regex
  variables <- names(list.search(estructura, .[grepl(pattern, .)], 'character'))
  variables <- sapply(lapply(variables, 
                             str_match, 
                             pattern = "variable.(.*).tipo"),
                      function(x) x[2])
  return(variables)
}

get_var_from_name <- function(estructura, pattern){
  # Obtener variable del yaml con regex
  variables <- purrr::flatten(estructura) %>% unlist() %>% names() %>% list()
  variables <- list.search(variables, .[grepl(pattern,.)])
  variables <- lapply(variables, 
                      str_match, 
                      pattern = "variable.(.*).tipo")[[1]][,2]
  return(unique(variables))
}

to_numeric <- function(data, variables){
  data[variables] <- sapply(data[variables], as.character)
  data[variables]<- sapply(data[variables], as.numeric)
  return(data)
}

plot_map <- function(data, variable, palette){
  data["value"] <-  data[variable]
  mxmunicipio_choropleth(data, 
                         num_colors = 8,
                         title = variable,
                         legend = variable) +
    scale_fill_brewer(palette = palette, na.value=NA,  name = variable) 
}  