import igraph

from anyascii import anyascii

from .scopus import query_scopus
from .scopus_enrichment import enrich_coauthors, enrich_author_components, enrich_author_communities


class ScopusGraph(object):
    """
    General functions for creating a graph from scopus data
    """

    def __init__(self, graph=None):
        if graph:
            self.graph = graph
        else:
            self.graph = igraph.Graph()

    def import_date_range(self, journal_issn_map, decade_start, decade_end, query_fmt):
        "Import a date range of articles from scopus for given journals"

        for journal in journal_issn_map.keys():
            issn = journal_issn_map[journal]['issn']
            query_str = query_fmt.format(issn=issn)

            print(f"Add journal {journal}; query: {query_str}")
            self.add_journal_date_range(decade_start, decade_end, query_str=query_str)

    def import_all(self, journal_issn_map, query_fmt):
        "Import all articles from scopus for given journals"
        for journal in journal_issn_map.keys():
            issn = journal_issn_map[journal]['issn']
            query_str = query_fmt.format(issn=issn)

            print(f"Add journal {journal} {issn}")
            self.add_journal(query_str=query_str)

    def add_journal_date_range(self, decade_start, decade_end, query_str):
        for article in query_scopus(query_str).results:
            article_year = int(article.coverDate.split("-")[0])
            if article_year >= decade_start and article_year <= decade_end:
                self.add_article(article)

    def add_author(self, author_name, scopus_id):
        author_name_ascii = anyascii(author_name)

        try:
            author_vertex = self.graph.vs.find(scopus_id=scopus_id, node_type="author")
        except (ValueError, KeyError):
            author_vertex = self.graph.add_vertex(
                node_type='author',
                author_name=author_name_ascii,
                scopus_id=scopus_id,
                label=f"Author {author_name_ascii} ({scopus_id})",
            )

        return author_vertex

    def add_article(self, article):
        if not article.title:
            return

        title_ascii = anyascii(article.title)
        abstract_ascii = anyascii(article.description) if article.description else ""
        keywords_ascii = anyascii(article.authkeywords) if article.authkeywords else ""

        article_vertex = self.graph.add_vertex(
            node_type='article',
            doi=article.doi,
            issn=article.issn,
            title=title_ascii,
            cover_date=article.coverDate,
            volume=article.issueIdentifier,
            abstract=abstract_ascii.encode("ascii", "ignore"),
            journal=article.publicationName,
            keywords=keywords_ascii,
            label=f"Article {title_ascii}",
            citedby_count=article.citedby_count,
        )

        if article.author_ids:
            author_list = zip(article.author_names.split(';'), article.author_ids.split(';'))
            for author_name, scopus_id in author_list:
                author_vertex = self.add_author(author_name, scopus_id)
                new_edge = self.graph.add_edge(author_vertex.index, article_vertex.index)
                new_edge["edge_type"] = "authored"

    def add_journal(self, query_str):
        print(f"Query: {query_str}")
        for article in query_scopus(query_str).results:
            self.add_article(article)

    def get_articles(self):
        return self.graph.subgraph(vertices=[ v for v in self.graph.vs() if v["node_type"] == "article"])

    def get_authors(self):
        return self.graph.subgraph(vertices=[ v for v in self.graph.vs() if v["node_type"] == "author"])

    def load_graphml(self, filename):
        self.graph = igraph.Graph.Read_GraphML(filename)
        print("loaded graph")

    def save_graphml(self, filename):
        print(f"Save graph to {filename}")
        self.graph.write_graphml(filename)
        print(f"Saved")

    def enrich(self):
        enrich_coauthors(self.graph)
        enrich_author_components(self.graph)
        enrich_author_communities(self.graph)
