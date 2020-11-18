#!/usr/bin/env python3

import igraph
import pandas
from pybliometrics.scopus import ScopusSearch


journal_issn_map = {
    'JPSP': {
        'issn': '0022-3514',
    },
    'JRP': {
        'issn': '0092-6566',
    },
    'JP': {
        'issn': '0022-3506',
    },
    'EJP': {
        'issn': '0890-2070',
    },
    'PID': {
        'issn': '0191-8869',
    },
    'PSPB': {
        'issn': '0146-1672',
    },
    'PSPR': {
        'issn': '1088-8683',
    },
    'SPPS': {
        'issn': '1948-5506',
    },
    'JPA': {
        'issn': '0022-3891',
    },
    'SBP': {
        'issn': '0301-2212',
    }
}


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
    coauthors = graph.cocitation(authors)

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


def add_journal(graph, issn_str):
    articles = query_scopus(f'ISSN ( {issn_str} )').results

    for article in articles:
        graph = add_article(graph, article)

    return graph


def build_graph(journal_issn_map, graph_filename):
    graph = igraph.Graph(directed=False)
    for journal in journal_issn_map.keys():
        issn = journal_issn_map[journal]['issn']
        print(f"Add journal {journal} (ISSN: {issn})")
        graph = add_journal(graph, issn)
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


def main():
    # graph = build_graph(journal_issn_map, "personality.graphml")

    graph = get_graph("personality.graphml")
    graph = enrich_coauthors(graph)
    author_graph = get_authors(graph)
    author_graph.write_graphml("personality-coauthors.graphml")

    print(graph)


if __name__ == "__main__":
    main()
