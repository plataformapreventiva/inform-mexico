setwd("~/workspace/inform-mexico/")
dotenv::load_dot_env(".env")
paquetines <- c("dbrsocial","ggplot2","tidyverse","plyr","scales",
                "maptools","rgdal","ggmap","gridExtra","rgdal",
                "Hmisc","rgeos","sp","sf","rgeos","broom","scales",
                "rangeMapper","ggmap","plotly","viridis", "DataExplorer",
                "glue","data.table", "stringr","gsubfn")
no_instalados <- paquetines[!(paquetines %in% installed.packages()[,"Package"])]
if(length(no_instalados)) install.packages(no_instalados)
lapply(paquetines, library, character.only = TRUE)

### DB conections
con <- prev_connect()


# Funciones

load_query <- function(connection,schema,the_table,columns="*",options=""){
  the_query <- "SELECT %s FROM %s.%s"
  complete <- paste0(the_query," ",options)
  schema    <- deparse(substitute(schema))
  the_table <- deparse(substitute(the_table))
  initial <- RPostgreSQL::dbSendQuery(connection,
                                      sprintf(complete,columns,schema,the_table))
}

load_geom <- function(connection,schema,the_table,columns="cve_mun, cve_ent, cve_muni, ", geom_col, col_shape, options=""){
  geom_col <- deparse(substitute(geom_col))
  schema    <- deparse(substitute(schema))
  the_table <- deparse(substitute(the_table))
  col_shape <- deparse(substitute(col_shape))
  
  the_query <- "SELECT %s FROM %s.%s"
  geom_col_as <- sprintf("ST_AsText(%s) as geom",geom_col)
  columns <- paste0(columns,geom_col_as)
  complete <- paste0(the_query," ",options)
  
  initial <- RPostgreSQL::dbSendQuery(connection,
                                      sprintf(complete,columns,schema,the_table)) %>%
    retrieve_result()
  
  mun_shp = WKT2SpatialPolygonsDataFrame(initial, geom = geom_col, id = col_shape)
  mun_df <- fortify(mun_shp, region = col_shape)
  names(mun_df)[names(mun_df)=="id"] <- col_shape
  
  return(mun_df)
}

theme_pub <- function(base_size=12, font=NA){
  txt <- element_text(size = base_size+2, colour = "black", face = "plain")
  bold_txt <- element_text(size = base_size+2, colour = "black", face = "bold")
  
  theme_classic(base_size = base_size, base_family = font) +
    
    theme(plot.title = element_text(size = 30, face = "bold"),
          axis.title.x = element_text(size=20),
          axis.title.y = element_text(size=20),
          axis.text.x = element_text(angle = 45, size=22, hjust = 1),
          axis.text.y = element_text(size=22),
          legend.text = element_text(size=10))
}

quant_labels <- function(variable, no_classes=6){
  quantiles <- quantile(variable, 
                        probs = seq(0, 1, length.out = no_classes + 1),na.rm = TRUE)
  labels <- c()
  for(idx in 1:length(quantiles)){labels <- c(labels, paste0(round(quantiles[idx], 2)," – ", round(quantiles[idx + 1], 2))) }
  labels <- labels[1:length(labels)-1]
  variable_q <- cut(variable, breaks = quantiles,labels = labels, include.lowest = T)
  return(variable_q)
}



create_reports <- function(df, task_name, output_dir){
  df <- data.table(df)
  output_file <- glue('{task_name}.html')
  output_dir <- glue('{output_dir}')
  create_report(data = df , output_file = output_file, output_dir = output_dir)
}

