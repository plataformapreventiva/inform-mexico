#!/usr/bin/env python
import yaml
import os
import pdb
import pandas as pd

from itertools import product
from sqlalchemy import create_engine
from dotenv import load_dotenv,find_dotenv
from dotenv import load_dotenv,find_dotenv

import plotter

load_dotenv(find_dotenv())

def read_yaml(config_file_name):
    """
    This function reads the config file
    Args:
       config_file_name (str): name of the config file
    """
    with open(config_file_name, 'r') as f:
        config = yaml.load(f)
    return config


def get_engine():
    """
    Get SQLalchemy engine using credentials.
    """

    url = 'postgresql://{user}:{passwd}@{host}:{port}/{db}'.format(
                                                            user=os.environ.get("POSTGRES_USER"),
                                                            passwd=os.environ.get("POSTGRES_PASSWORD"),
                                                            host=os.environ.get("PGHOST"),
                                                            port=5432,
                                                            db=os.environ.get("PGDATABASE"))
    engine = create_engine(url)
    return engine


def read_table(engine, config, table_name):
    table = config[table_name]
    conditions_cols = [x for x in table.keys() if x not in ['schema', 'variable']]
    if conditions_cols:
        conds = []
        for key in conditions_cols:
           conds.append("{key}::TEXT = '{val}'".format(key=key,
                                          val=table[key]))
        conditions = " AND " + " AND ".join(conds)
    else:
        conditions = ""

    variables = ", ".join("'{}'".format(x) for x in table['variable'])
    query = ("""SELECT clave, variable, valor
                FROM {schema}.{table_name}
                WHERE variable in ({vars})
                {conditions}""".format(schema=table['schema'],
                                       table_name=table_name,
                                       vars=variables,
                                       conditions=conditions))

    df = pd.read_sql(query, engine)

    if df.empty:
        return df
    else:
        df_spread = df.pivot_table(index='clave', columns='variable', values='valor', aggfunc='first')
        #df_spread.columns = df_spread.columns.get_level_values(1)
        df_spread.reset_index(inplace=True)
        return df_spread


def box_plot(config, engine):
    save_path = config['save_plots_path']

    label = config['boxplots']['label']
    values = config['boxplots']['values']

    label_table = read_table(engine, config, label)
    values_table = read_table(engine, config, values)

    labels = [x for x in  config[label]['variable'] if x != 'variable']
    var_values = [x for x in  config[values]['variable'] if x != 'variable']
    res = pd.merge(label_table, values_table, on='clave')

    plots = plotter.plot_features_boxplot(res, labels, var_values)
    plotter.save_plot(plots, save_path, 'boxplots/{}_{}'.format(label, values), n_cols=3)

def histogram(config, engine):
    save_path = config['save_plots_path']
    tables = config['histograms']

    for table in tables:
        df = read_table(engine, config, table)
        if not df.empty:
            plots = plotter.plot_feature_histograms(df, nbins=50)
            # Save plots
            plotter.save_plot(plots, save_path, 'histograms/' + table, n_cols=3)

def corrplots(config, engine):
    save_path = config['save_plots_path']
    table = config['corplot']

    df = read_table(engine, config, table)
    if not df.empty:
        plots = plotter.plot_feature_corrplots(df)
        plotter.save_plot(plots, save_path, 'corplots/' + table, n_cols=3)

if __name__ == "__main__":
    config = read_yaml('tables.yaml')

    engine = get_engine()
#    corrplots(config, engine)
#    box_plot(config, engine)
    histogram(config, engine)

