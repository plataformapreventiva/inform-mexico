#!/usr/bin/env python
import pandas as pd
import numpy as np
import pdb
import argparse
from bokeh.plotting import figure, show
from bokeh.palettes import Set1
from bokeh.io import save
from bokeh.layouts import gridplot
from bokeh.models.glyphs import Circle, Line
from bokeh.models import ColumnDataSource, Grid, LinearAxis, Plot, Range1d
from bokeh.resources import CDN
from scipy.stats import ks_2samp

def plot_feature_corrplots(df):
    res = []
    cols = [x for x in df.columns if x != 'clave']

    circles_source = ColumnDataSource(
        data = df.to_dict(orient='list')
    )
    for i in range(len(cols)):
        for j in range(i+1, len(cols)):
            # vars
            xvar = df[cols[i]]
            yvar = df[cols[j]]

            xdr = Range1d(start=min(df[cols[i]]) - .1, end=max(df[cols[i]])+ .1)
            ydr = Range1d(start=min(df[cols[j]]) - .1, end=max(df[cols[j]]) + .1)

            plot = figure(x_range=xdr, y_range=ydr,
                        plot_width=400, plot_height=400,
                        border_fill_color='white',
                        background_fill_color='#e9e0db',
                        tools=["save","zoom_in", "zoom_out", "box_zoom", "reset", "pan"])
            plot.title.text = '{} y {}'.format(cols[i], cols[j])
            #xaxis = LinearAxis(axis_line_color=None)
            #plot.add_layout(xaxis, 'below')

            #yaxis = LinearAxis(axis_line_color=None)
            #plot.add_layout(yaxis, 'left')

            #plot.add_layout(Grid(dimension=0, ticker=xaxis.ticker))
            #plot.add_layout(Grid(dimension=1, ticker=yaxis.ticker))

            circle = Circle(
                x=cols[i], y=cols[j], size=8,
                fill_color="#cc6633", line_color="#cc6633", fill_alpha=0.5
                )
            plot.add_glyph(circles_source, circle)
            res.append(plot)
    return res


def plot_feature_histograms(df, nbins=50):
    """
    Takes a list of dataframes with equal columns. For each column, 
    from that list, creates a histogram that contrasts the distribution of 
    that column's values between dataframes.
    Note: The returned plots are returned in the same order as they appear 
    in df_list[0].
    Args:
        df: dataframe
        columns: list of columns of dataframe
        nbins: the number of bins in the histograms
        colors: list of colors to use; uses a standard palette by default
    Returns:
        List of bokeh.figures
    """
    # now we can plot each column, grouped by the dataframe name
    res = []
    cols = [x for x in df.columns if x != 'clave']
    for col in cols:

        # get the bin sizes
        all_values = df[col]
        _, all_edges = np.histogram(all_values, bins=nbins)

        # make a figure
        p = figure(title="Distribution of %s"%col, tools=["save","zoom_in",
            "zoom_out", "box_zoom", "reset", "pan"],
            background_fill_color="#ffffff")

        hist, edges = np.histogram(df[col], density=True, bins=all_edges)
        p.quad(top=hist, bottom=0, left=edges[:-1], right=edges[1:],
                   fill_color="green", line_color="green",
                   alpha=0.8)

        #p.legend.location = 'top_right'
        p.xaxis.axis_label = col
        p.yaxis.axis_label = 'density'
        res.append(p)

    return res


def save_plot(plots, save_path, outfile, n_cols=3):
    # save HTML plots
    save(gridplot(*plots, ncols=int(n_cols), plot_width=600, plot_height=400,
        toolbar_location='above'), save_path + str(outfile) + '.html', resources=CDN,
        title='')


def plot_features_boxplot(df, labels, var_values):
    res = []
    for label in labels:
        unique_vals = list(df[label].unique())

        for col in var_values:
            groups = df.groupby(label)[col]
            q1 = groups.quantile(q=0.25)
            q2 = groups.quantile(q=0.5)
            q3 = groups.quantile(q=0.75)
            iqr = q3 - q1
            upper = q3 + 1.5*iqr
            lower = q1 - 1.5*iqr
            # find the outliers for each category
            def outliers(group):
                cat = group.name
                return group[(group > upper.loc[cat]) | (group < lower.loc[cat])]
            out = groups.apply(outliers).dropna()

            # prepare outlier data for plotting, we need coordinates for every outlier.
            if not out.empty:
                outx = []
                outy = []
                for cat in unique_vals:
                    # only add outliers if they exist
                    if not out.loc[cat].empty:
                        for value in out[cat]:
                            outx.append(cat)

            p = figure(background_fill_color="#EFE8E2",
                       title="Box plot {} vs {}".format(label, col),
                        tools=["save","zoom_in", "zoom_out", "box_zoom", "reset", "pan"],
                       x_range=unique_vals)
            # if no outliers, shrink lengths of stems to be no longer than the minimums or maximums
            qmin = groups.quantile(q=0.00)
            qmax = groups.quantile(q=1.00)
            upper = [min([x,y]) for (x,y) in zip(list(qmax),upper)]
            lower = [max([x,y]) for (x,y) in zip(list(qmin),lower)]
            p.segment(unique_vals, upper, unique_vals, q3, line_color="black")
            p.segment(unique_vals, lower, unique_vals, q1, line_color="black")

            # boxes
            p.vbar(unique_vals, 0.7, q2, q3, fill_color="#E08E79", line_color="black")
            p.vbar(unique_vals, 0.7, q1, q2, fill_color="#3B8686", line_color="black")

            # whiskers (almost-0 height rects simpler than segments)
            p.rect(unique_vals, lower, 0.2, 0.01, line_color="black")
            p.rect(unique_vals, upper, 0.2, 0.01, line_color="black")
            # outliers
            if not out.empty:
                p.circle(outx, outy, size=6, color="#F38630", fill_alpha=0.6)

            p.xgrid.grid_line_color = None
            p.ygrid.grid_line_color = "white"
            p.grid.grid_line_width = 2
            p.xaxis.major_label_text_font_size="12pt"
            res.append(p)

    return res
