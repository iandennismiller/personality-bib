def enrich_author_communities(graph):
    print("compute author communities")

    authors = graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "author" and v["component_id"] == 0])
    if len(authors.vs()) > 10000:
        # resolution = 0.000025 # 5 communities
        # resolution = 0.000027 # 251 communities
        resolution = 0.001 # 201 communities
    elif len(authors.vs()) > 1000:
        resolution = 0.1
    else:
        resolution = 0.0005

    # clusters = community_louvain.best_partition(authors)
    # print(clusters)
    while resolution > 0.0000001:
        clusters = authors.community_leiden(resolution=resolution, n_iterations=-1)
    # clusters = authors.community_leiden(resolution=resolution, objective_function="modularity", n_iterations=-1)
    # clusters = authors.community_louvain()
    # clusters = authors.community_fastgreedy()
    
        membership = clusters.membership
        print(f"{resolution},{len(set(membership))}")
        resolution -= 0.0000001

    sys.exit()

    for author, community_id in zip(authors.vs(), membership):
        # link via scopus_id; find vertex in original graph corresponding to authors subgraph
        scopus_id = author["scopus_id"]
        author_vertex = graph.vs.find(scopus_id=scopus_id, node_type="author")
        author_vertex["community_id"] = community_id

    return graph

def enrich_article_communities(graph):
    print("compute article communities")

    articles = graph.subgraph(vertices=[ v for v in graph.vs() if v["node_type"] == "article"])

    no_authors_count = 0

    for article in articles.vs():
        # link via title; find vertex in original graph corresponding to article in subgraph
        title = article["title"]
        article_vertex = graph.vs.find(title=title, node_type="article")

        # get authored-by edges from the article vertex
        # authored_by_edges_target = graph.es.select(_target=article_vertex.index, edge_type="authored")
        # authored_by_edges = graph.es.select(_incident=article_vertex.index, edge_type="authored")
        authored_by_edges_source = graph.es.select(_source=article_vertex.index, edge_type="authored")

        if len(authored_by_edges_source) > 0:
            authored_by_edges = authored_by_edges_source
        # elif len(authored_by_edges_source) > 0:
        #     authored_by_edges = authored_by_edges_source
        else:
            no_authors_count += 1
            authored_by_edges = []
            # print(f"article {article} has no authors")

        if len(authored_by_edges) > 0:
            author_vertices = [ graph.vs()[e.target] for e in authored_by_edges ]
            author_vertices += [ graph.vs()[e.source] for e in authored_by_edges ]
            mode_community_id = statistics.mode([a['community_id'] for a in author_vertices if a['community_id'] is not None])
            article_vertex["community_id"] = mode_community_id

            # print(f"article {article} has community {mode_community_id}")
            # print(mode_community_id)
        else:
            article_vertex["community_id"] = None

    print(f"number of articles with no authors: {no_authors_count}")
