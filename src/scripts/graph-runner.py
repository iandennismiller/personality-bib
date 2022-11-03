#!/usr/bin/env python3

import sys
import click
import igraph
import pandas
from pybliometrics.scopus import ScopusSearch

sys.path.insert(0, '.')

from personality_bib.builder import build_per_decade, build_all_time

@click.group()
def cli():
    pass


@click.command('repl')
def repl():
    import IPython
    IPython.embed()


@click.command('per-decade')
@click.option('--path', default="data/graphs", required=True)
def do_build_per_decade(path):
    decade_list = [
        [1970, 1979], 
        [1980, 1989], 
        [1990, 1999], 
        [2000, 2009], 
        [2010, 2020], 
    ]
    build_per_decade(decade_list, path)


@click.command('90s')
@click.option('--path', default="data/graphs", required=True)
def do_build_90s(path):
    decade_list = [
        [1990, 1999], 
    ]
    build_per_decade(decade_list, path)


@click.command('all-time')
@click.option('--path', default="data/graphs", required=True)
def do_build_all_time(path):
    build_all_time(path)


cli.add_command(repl)
cli.add_command(do_build_90s)
cli.add_command(do_build_all_time)
cli.add_command(do_build_per_decade)

cli()
