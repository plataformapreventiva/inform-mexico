#!/usr/bin/env Rscript
library(rlang)
library(yaml)
library(purrr)
library(magrittr)
library(dbrsocial)

source('pipeline_utils.R')

dotenv::load_dot_env("../../.env")

# Read config
yml_name <- 'variables-tree.yaml'
var_tree <- read_yaml(yml_name)

dodo <- function(type, dimensions){
    if (type == 'subdim'){
        names_sub <- names(dimensions)
        for (name_sub in names_sub){
            c(long_name, aggregation, weight, dimensions, type) := dim_block(dimensions, name_sub)
            return(dodo(type, dimensions)
        }
    if (type == 'vars'){
        
    }
}

# Get all dimension names
names_dims <- names(var_tree)

# Loop through the dimension names:
name_dim <- names_dims[1]
c(dim_name, dim_agg, dim_weight, dimensions, dim_type) := dim_block(var_tree, name_dim)

if type == 'subdim' {
    names_sub <- names(dimensions)
    name_sub <- names_sub[1]
    c(long_name, aggregation, weight,
      dimensions, type) := dim_block(dimensions, name_sub)
    if type == 'subdim' {
        names_subsub <- names(dimensions)
    }

}

subdim_names <- names(dim_subdims)

variable_block <- function(config, name) {

    # get subconfig
    sub_config <- config[[c(name)]]
    # return parameters
    long_name <- subconfig[[1]]$name
    table_name <- subconfig[[2]]$table
    direction <- subconfig[[3]]$direction
    type <- subconfig[[4]]$type
    weight <- subconfig[[5]]$weight
    treatment <- try(subconfig[[6]]$treatment)
    # Read variable from table
    table_name <- stringr::str_split(table_name, '\\.')
    con <- prev_connect()
    var <- dplyr::tbl(con, dbplyr::in_schema(table_name[1], table_name[2])) %>%
        select(!! name)

    # Apply treatment if needed
    if ( !is.na(treatment)) {
        var <- eval(treatmente)
    }

}

dim_block <- function(config, name) {
    # get subconfig
    sub_config <- config[[c(name)]]
    # return parameters
    long_name <- sub_config[[1]]$name
    aggregation <- sub_config[[2]]$aggregation
    weight <- sub_config[[3]]$weight
    dimensions <- try(sub_config[[4]]$dimensions)
    variables <- try(sub_config[[4]]$variables)
    # check if dimension of variables go next
    if (length(dimensions) > 0 ) {
        return (list(long_name, aggregation, weight, dimensions, 'subdim'))
    } else if (length(variables) > 0 ) {
        return (list(long_name, aggregation, weight, variables, 'vars'))
    }
}

