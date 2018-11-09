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
              "tidyverse", "stringr", "corrplot", "mxmaps")
lapply(paquetes, instalar);
#library("df_mxmunicipio")
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
  return(print(varx))
}
