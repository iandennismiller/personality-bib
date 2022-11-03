# -*- coding: utf-8 -*-
# Ian Dennis Miller

from setuptools import setup, find_packages
import os
import re

meta_filename = 'personality_bib/__meta__.py'

def fpath(name):
    return os.path.join(os.path.dirname(__file__), name)

def read(fname):
    return open(fpath(fname)).read()

def grep(attrname):
    pattern = r"{0}\W*=\W*'([^']+)'".format(attrname)
    strval, = re.findall(pattern, read(fpath(meta_filename)))
    return strval

setup(
    version=grep('__version__'),
    name='personality-bib',
    description="personality-bib",
    packages=find_packages(),
    scripts=[
        "scripts/graph-runner.py",
    ],
    # long_description=read('../Readme.md'),
    include_package_data=True,
    keywords='',
    author=grep('__author__'),
    author_email=grep('__email__'),
    url=grep('__url__'),
    license='unlicensed',
    zip_safe=False,
    # install_requires=[
    # ],
    # extras_require={
    #     "tag": [
    #     ],
    # },
)
