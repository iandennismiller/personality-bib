import igraph

from .scopus_graph import ScopusGraph
from . import journal_issn_map, interdisciplinary_journal_issn_map, top_personality_journal_issn_map


def build_per_decade(decade_list, filename_fmt="../products/graphs/journals-{decade_start}s.graphml"):

    for decade_start, decade_end in decade_list:
        print(f"Start decade {decade_start}-{decade_end}")
        
        graph = ScopusGraph()

        # add articles from interdisciplinary journals
        graph.import_date_range(
            interdisciplinary_journal_issn_map,
            decade_start=decade_start,
            decade_end=decade_end,
            query_fmt='ISSN ( {issn} ) AND TITLE-ABS-KEY ( personality )'
        )

        # include everything from the top personality articles
        graph.import_date_range(
            top_personality_journal_issn_map,
            decade_start=decade_start,
            decade_end=decade_end,
            query_fmt='ISSN ( {issn} )'
        )

        graph.enrich_coauthors()
        graph.save_graphml(filename_fmt.format(decade_start=decade_start))

    # return the final graph
    return graph


def build_all_time(filename="../products/graphs/journals.graphml"):
    graph = ScopusGraph()

    graph.import_all(
        top_personality_journal_issn_map,
        query_fmt='ISSN ( {issn} )'
    )

    graph.import_all(
        interdisciplinary_journal_issn_map,
        query_fmt='ISSN ( {issn} ) AND TITLE-ABS-KEY ( personality )'
    )

    graph.enrich_coauthors(graph)
    graph.save_graphml(filename)
    return graph
