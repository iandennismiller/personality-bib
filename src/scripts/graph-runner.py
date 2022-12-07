#!/usr/bin/env python3

import click

from personality_bib.personality_graph import build_per_decade, build_all_time


@click.group()
def cli():
    pass

@click.command('repl')
def repl():
    import IPython
    IPython.embed()

@click.command('per-decade')
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

@click.command('90s')
@click.option('--path', default="var", required=True)
def do_build_90s(path):
    filename_fmt=f"{path}/test-{{decade_start}}s.graphml"
    print(filename_fmt)

    decade_list = [
            [1990, 1999], 
        ]

    build_per_decade(decade_list, filename_fmt)

@click.command('all-time')
@click.option('--filename', default="var", required=True)
def do_build_all_time(filename):
    build_all_time(filename)


cli.add_command(repl)
cli.add_command(do_build_90s)
cli.add_command(do_build_all_time)
cli.add_command(do_build_per_decade)

cli()
