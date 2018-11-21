#!/usr/bin/env Rscript

# Dependencies

paquetes <- c("ggplot2","tidyverse","plyr","scales",
              "maptools","rgdal","ggmap")
no_instalados <- paquetes[!(paquetes %in% installed.packages()[,"Package"])]
if(length(no_instalados)) install.packages(no_instalados)
lapply(paquetes, library, character.only = TRUE)
