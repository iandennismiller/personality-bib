import statistics
from pprint import pprint


def enrich(graph):
    enrich_coauthors(graph)
    enrich_author_components(graph)
    enrich_author_communities(graph)
    enrich_article_components(graph)
    enrich_article_communities(graph)

def enrich_coauthors(graph):
    "Identify coauthors based on shared articles"

    # obtain all authors
    authors = [ v for v in graph.vs() if v["node_type"] == "author" ]

    print("compute bibcoupling")
    coauthors = graph.cocitation(authors)

    print("create co-authorship edges")
    new_edge_vertices = []

    for author_idx in range(0, len(coauthors)):
        # who did this author coauthor with?
        author_coauthored_with = coauthors[author_idx]

        # for each potential coauthor, create an edge
        for coauthor_idx in range(0, len(author_coauthored_with)):

            # when the coauthorship is true, create an edge
            if author_coauthored_with[coauthor_idx]:
                new_edge_vertices.append([
                    authors[author_idx],
                    graph.vs()[coauthor_idx]
                ])

    graph.add_edges(
        es=new_edge_vertices,
        attributes={"edge_type": [ "coauthor" for x in range(0, len(new_edge_vertices)) ]}
    )
    return graph

def enrich_author_components(graph):
    print("compute author components")

    authors = graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "author"])
    components_unsorted = authors.connected_components(mode='strong')
    components = sorted(components_unsorted, key=len, reverse=True)

    for component_id in range(len(components)):
        members = components[component_id]
        for author_id in members:
            author = authors.vs()[author_id]
            # link via scopus_id; find vertex in original graph corresponding to authors subgraph
            scopus_id = author["scopus_id"]
            author_vertex = graph.vs.find(scopus_id=scopus_id, node_type="author")
            author_vertex["component_id"] = component_id

def enrich_author_communities(graph):
    print("compute author communities")

    authors = graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "author"])
    clusters = authors.community_leiden()
    membership = clusters.membership

    for author, community_id in zip(authors.vs(), membership):
        # link via scopus_id; find vertex in original graph corresponding to authors subgraph
        scopus_id = author["scopus_id"]
        author_vertex = graph.vs.find(scopus_id=scopus_id, node_type="author")
        author_vertex["community_id"] = community_id

    return graph

def enrich_article_components(graph):
    print("compute article components")

    articles = graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "article"])

    for article in articles.vs():
        # link via title; find vertex in original graph corresponding to article in subgraph
        title = article["title"]
        article_vertex = graph.vs.find(title=title, node_type="article")

        # get an authored-by edge from the article vertex
        authored_by_edges = graph.es.select(_target=article_vertex.index, edge_type="authored")
        

        if len(authored_by_edges) > 0:
            author_vertices = [ graph.vs()[e.target] for e in authored_by_edges ]
            first_author = author_vertices[0]
            article_vertex["component_id"] = first_author["component_id"]
        else:
            # print(f"article {article} has no authors")
            article_vertex["component_id"] = None

def enrich_article_communities(graph):
    print("compute article communities")

    articles = graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "article"])

    for article in articles.vs():
        # link via title; find vertex in original graph corresponding to article in subgraph
        title = article["title"]
        article_vertex = graph.vs.find(title=title, node_type="article")

        # get authored-by edges from the article vertex
        authored_by_edges = graph.es.select(_target=article_vertex.index, edge_type="authored")

        if len(authored_by_edges) > 0:
            author_vertices = [ graph.vs()[e.target] for e in authored_by_edges ]
            mode_community_id = statistics.mode([a['community_id'] for a in author_vertices])
            article_vertex["community_id"] = mode_community_id
        else:
            article_vertex["community_id"] = None
