from pybliometrics.scopus import ScopusSearch


def query_scopus(query_str):
    "query scopus, return results from cache"
    s = ScopusSearch(query_str, refresh=1200)
    print(f"Obtained {s.get_results_size()} results")
    return s
