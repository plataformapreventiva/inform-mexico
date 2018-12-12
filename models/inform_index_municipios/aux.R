#!/usr/bin/env Rscript

# Dependencies

paquetes <- c("optparse", "mice",
              "psych", "car",
              "rlist", "stringr",
              "classInt", "tidyr",
              "scales")
no_instalados <- paquetes[!(paquetes %in% installed.packages()[,"Package"])]
if(length(no_instalados)) install.packages(no_instalados)
lapply(paquetes, library, character.only = TRUE)


# Functions

get_cuts<-function(data, varx){
  # Generación de Cortes

  yy<-as.numeric(unlist(data[,varx] ) )
  yy<-yy[!is.infinite(yy)]
  ## Se revisa orientación: ¿más es mejor o menos es mejor?
  classes<-classIntervals(var=yy, n=5, style="kmeans") ## Se encuentran los puntos de corte
  cutoffs<-classes$brks
  yy<-as.numeric(unlist(data[,varx])) ## No se tiran na's (data ya imputado)
  data[,varx] <<- cut(x=yy, include.lowest = T, breaks=cutoffs, labels=c(0,25,50,75,100))
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
