#!/usr/bin/env python3

import click

from personality_bib.personality_graph import build_per_decade, build_all_time


@click.group()
def cli():
    pass

@cli.command('repl')
def repl():
    import IPython
    IPython.embed()

@cli.command('per-decade')
@click.option('--path', default="var", required=True)
def do_build_per_decade(path):
    filename_fmt=f"{path}/journals-{{decade_start}}s.graphml"
    print(filename_fmt)

    decade_list = [
        [1970, 1979], 
        [1980, 1989], 
        [1990, 1999], 
        [2000, 2009], 
        [2010, 2020], 
    ]
    build_per_decade(decade_list, filename_fmt)

@cli.command('one-decade')
@click.option('--path', default="var", required=True)
@click.option('--decade', required=True)
def do_build_one_decade(path, decade):
    if decade == "80s":
        decade_list = [1980, 1989]
    elif decade == "90s":
        decade_list = [1990, 1999]
    elif decade == "00s":
        decade_list = [2000, 2009]
    elif decade == "10s":
        decade_list = [2010, 2019]

    filename_fmt=f"{path}/journals-{{decade_start}}s.graphml"
    print(filename_fmt)
    build_per_decade(decade_list, filename_fmt)

@cli.command('all-time')
@click.option('--filename', default="var", required=True)
def do_build_all_time(filename):
    build_all_time(filename)

cli()
