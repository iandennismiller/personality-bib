#!/usr/bin/env python3

import igraph
import pandas
from pybliometrics.scopus import ScopusSearch


journal_issn_map = {
    'JPSP': { 'issn': '0022-3514' },
    'JRP': { 'issn': '0092-6566' },
    'JP': { 'issn': '0022-3506' },
    'EJP': { 'issn': '0890-2070' },
    'PID': { 'issn': '0191-8869' },
    'PSPB': { 'issn': '0146-1672' },
    'PSPR': { 'issn': '1088-8683' },
    'SPPS': { 'issn': '1948-5506' },
    'JPA': { 'issn': '0022-3891' },
    'SBP': { 'issn': '0301-2212' }
}

interdisciplinary_journal_issn_map = {
    "Journal of Personality and Social Psychology": {"issn": "0022-3514"},
    "Personality and Social Psychology Bulletin": {"issn": "0146-1672"},
    "Personality and Social Psychology Review ": {"issn": "1088-8683"},
    "Social Psychological and Personality Science ": {"issn": "1948-5506"},
    "Psychological Assessment":	{"issn": "1040-3590"},
    "Assessment": {"issn": "1073-1911"},
    "Psychological Inquiry": {"issn": "1047-840X"},
    "Psychological Bulletin": {"issn": "0033-2909"},
    "Psychological Review":	{"issn": "0033-295X"},
    "American Psychologist": {"issn": "0003-066X"},
    "SOCIAL BEHAVIOR AND PERSONALITY": {"issn": "0301-2212"},
    "Journal of Personality Assessment": {"issn": "0022-3891"},
}

top_personality_journal_issn_map = {
    "Journal of Research in Personality": {"issn": "0092-6566"},
    "Journal of Personality": {"issn": "0022-3506"},
    "European Journal of Personality": {"issn": "0890-2070"},
    "Personality and Individual Differences": {"issn": "0191-8869"},
}

###
# Per-decade

def add_article_by_decade(graph, article, decade_start, decade_end):
    article_year = int(article.coverDate.split("-")[0])
    if article_year >= decade_start and article_year <= decade_end:
        graph = add_article(graph, article)
    return graph


def add_journal_by_decade(graph, decade_start, decade_end, query_str):
    for article in query_scopus(query_str).results:
        graph = add_article_by_decade(graph, article, decade_start, decade_end)

    return graph


def build_graph_by_decade(graph, journal_issn_map, graph_filename, decade_start, decade_end, query_fmt='ISSN ( {issn} )'):
    for journal in journal_issn_map.keys():
        issn = journal_issn_map[journal]['issn']
        query_str = query_fmt.format(issn=issn)
        print(f"Add journal {journal}; query: {query_str}")
        graph = add_journal_by_decade(graph, decade_start, decade_end, query_str=query_str)
        graph.write_graphml(graph_filename)
        print("wrote to graphml")

    return graph

###
# Regular functions

# query scopus to build graph from results
def query_scopus(query_str):
    s = ScopusSearch(query_str)
    print(f"Obtained {s.get_results_size()} results")
    return s


def add_author(graph, author_name, scopus_id):
    try:
        author_vertex = graph.vs.find(scopus_id=scopus_id, node_type="author")
    except (ValueError, KeyError):
        author_vertex = graph.add_vertex(
            node_type='author',
            author_name=author_name,
            scopus_id=scopus_id,
            label=f"Author {author_name} ({scopus_id})",
        )

    assert author_vertex
    return graph


def add_article(graph, article):
    article_vertex = graph.add_vertex(
        node_type='article',
        doi=article.doi,
        issn=article.issn,
        title=article.title,
        cover_date=article.coverDate,
        volume=article.issueIdentifier,
        abstract=article.description,
        journal=article.publicationName,
        keywords=article.authkeywords,
        label=f"Article {article.title}",
    )
    assert article_vertex

    if article.author_ids:
        author_list = zip(article.author_names.split(';'), article.author_ids.split(';'))
        for author_name, scopus_id in author_list:
            graph = add_author(graph, author_name, scopus_id)
            author_vertex = graph.vs.find(scopus_id=scopus_id, node_type="author")
            new_edge = graph.add_edge(author_vertex.index, article_vertex.index)
            new_edge["edge_type"] = "authored"

    return graph


def enrich_coauthors(graph):
    authors = [ v for v in graph.vs() if v["node_type"] == "author" ]
    print("compute cocitation")
    coauthors = graph.cocitation(authors)

    print("create co-authorship edges")
    for author_idx in range(0, len(coauthors)):
        author_coauthored_with = coauthors[author_idx]

        for coauthor_idx in range(0, len(author_coauthored_with)):
            if author_coauthored_with[coauthor_idx]:
                new_edge = graph.add_edge(
                    graph.vs()[author_idx].index, 
                    graph.vs()[coauthor_idx].index
                )
                new_edge["edge_type"] = "coauthor"

    return(graph)


def add_journal(graph, query_str):
    for article in query_scopus(query_str).results:
        graph = add_article(graph, article)

    return graph


def build_graph(graph, journal_issn_map, graph_filename, query_fmt='ISSN ( {issn} )'):
    for journal in journal_issn_map.keys():
        issn = journal_issn_map[journal]['issn']
        query_str = query_fmt.format(issn=issn)
        print(f"Add journal {journal}; query: {query_str}")
        graph = add_journal(graph, query_str=query_str)
        graph.write_graphml(graph_filename)
        print("wrote to graphml")

    return graph


def get_articles(graph):
    return graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "article"])


def get_authors(graph):
    return graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "author"])


def get_graph(graph_filename):
    graph = igraph.Graph.Read_GraphML(graph_filename)
    return graph


def do_coauthorship(filename):
    graph = get_graph(filename)
    graph = enrich_coauthors(graph)
    author_graph = get_authors(graph)
    author_graph.write_graphml(f"coauthors-{filename}")


if __name__ == "__main__":
    decade_list = [
        [1970, 1979], 
        [1980, 1989], 
        [1990, 1999], 
        [2000, 2009], 
        [2010, 2020], 
    ]

    for decade_start, decade_end in decade_list:
        # graph = igraph.Graph(directed=False)
        # build_graph_by_decade(
        #     top_personality_journal_issn_map, 
        #     f"personality-journals-{decade_start}s.graphml",
        #     decade_start=decade_start,
        #     decade_end=decade_end,
        # )
        # do_coauthorship(f"personality-journals-{decade_start}s.graphml")

        # graph = igraph.Graph(directed=False)
        graph = get_graph(f"personality-journals-{decade_start}s.graphml")
        build_graph_by_decade(
            graph,
            interdisciplinary_journal_issn_map,
            f"merged-journals-{decade_start}s.graphml",
            decade_start=decade_start,
            decade_end=decade_end,
            query_fmt='ISSN ( {issn} ) AND TITLE-ABS-KEY ( personality )'
        )
        do_coauthorship(f"merged-journals-{decade_start}s.graphml")
