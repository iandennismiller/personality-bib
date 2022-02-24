import click
import igraph
import pandas
from pybliometrics.scopus import ScopusSearch

from . import journal_issn_map, interdisciplinary_journal_issn_map, top_personality_journal_issn_map

###
# Per-decade

def add_journal_by_decade(graph, decade_start, decade_end, query_str):
    for article in query_scopus(query_str).results:
        article_year = int(article.coverDate.split("-")[0])
        if article_year >= decade_start and article_year <= decade_end:
            add_article(graph, article)


def build_graph_by_decade(graph, journal_issn_map, decade_start, decade_end, query_fmt):
    for journal in journal_issn_map.keys():
        issn = journal_issn_map[journal]['issn']
        query_str = query_fmt.format(issn=issn)

        print(f"Add journal {journal}; query: {query_str}")
        add_journal_by_decade(graph, decade_start, decade_end, query_str=query_str)


###
# Regular functions

# query scopus to build graph from results
def query_scopus(query_str):
    print(query_str)
    s = ScopusSearch(query_str, refresh=1200)
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

    return author_vertex


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

    if article.author_ids:
        author_list = zip(article.author_names.split(';'), article.author_ids.split(';'))
        for author_name, scopus_id in author_list:
            author_vertex = add_author(graph, author_name, scopus_id)
            new_edge = graph.add_edge(author_vertex.index, article_vertex.index)
            new_edge["edge_type"] = "authored"


def add_journal(graph, query_str):
    print(f"Query: {query_str}")
    for article in query_scopus(query_str).results:
        add_article(graph, article)


def build_graph(graph, journal_issn_map, query_fmt):
    for journal in journal_issn_map.keys():
        issn = journal_issn_map[journal]['issn']
        query_str = query_fmt.format(issn=issn)

        print(f"Add journal {journal} {issn}")
        add_journal(graph, query_str=query_str)


def enrich_coauthors(graph):
    authors = [ v for v in graph.vs() if v["node_type"] == "author" ]

    print("compute bibcoupling")
    coauthors = graph.cocitation(authors)

    print("create co-authorship edges")
    new_edge_vertices = []

    for author_idx in range(0, len(coauthors)):
        author_coauthored_with = coauthors[author_idx]

        for coauthor_idx in range(0, len(author_coauthored_with)):
            if author_coauthored_with[coauthor_idx]:
                new_edge_vertices.append([
                    authors[author_idx],
                    graph.vs()[coauthor_idx]
                ])

    graph.add_edges(
        es=new_edge_vertices,
        attributes={"edge_type": [ "coauthor" for x in range(0, len(new_edge_vertices)) ]}
    )
 

def get_articles(graph):
    return graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "article"])


def get_authors(graph):
    return graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "author"])


def get_graph(graph_filename):
    graph = igraph.Graph.Read_GraphML(graph_filename)
    return graph


def build_per_decade(decade_list, path, filter_personality=False):
    for decade_start, decade_end in decade_list:
        print(f"Start decade {decade_start}-{decade_end}")

        graph = igraph.Graph(directed=False)
        
        # add articles from interdisciplinary journals
        build_graph_by_decade(
            graph,
            interdisciplinary_journal_issn_map,
            decade_start=decade_start,
            decade_end=decade_end,
            query_fmt='ISSN ( {issn} ) AND TITLE-ABS-KEY ( personality )'
        )

        # include everything from the top personality articles
        build_graph_by_decade(
            graph,
            top_personality_journal_issn_map,
            decade_start=decade_start,
            decade_end=decade_end,
            query_fmt='ISSN ( {issn} )'
        )

        enrich_coauthors(graph)
        graph.write_graphml(f"{path}/journals-{decade_start}s.graphml",)
        del(graph)


def build_all_time(path):
    graph = igraph.Graph(directed=False)

    # build_graph(
    #     graph,
    #     top_personality_journal_issn_map,
    #     query_fmt='ISSN ( {issn} )'
    # )

    build_graph(
        graph,
        interdisciplinary_journal_issn_map,
        query_fmt='ISSN ( {issn} ) AND NOT TITLE-ABS-KEY ( personality )'
    )

    enrich_coauthors(graph)
    graph.write_graphml(f"{path}/journals.graphml")
