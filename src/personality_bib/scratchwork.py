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

