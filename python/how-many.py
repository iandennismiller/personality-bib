# -*- coding: utf-8 -*-

from pybliometrics.scopus import ScopusSearch

def main():
    s = ScopusSearch('ISSN ( 0022-3514 )')
    print(s.get_results_size())

if __name__ == "__main__":
    main()
