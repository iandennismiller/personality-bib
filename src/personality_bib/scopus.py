from pybliometrics.scopus import ScopusSearch


def query_scopus(query_str):
    "query scopus, return results from cache"
    s = ScopusSearch(query_str, refresh=1200)
    return s
