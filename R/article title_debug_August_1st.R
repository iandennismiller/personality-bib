source("C:/Users/chris/Documents/GitHub/personality-bib/idm-science-networks/utils/coauthorship-graph-helper-functions.R")

setwd("C:/Users/chris/Documents/GitHub/personality-bib/Analyses")

library(tm)
library(stm)
library(igraph)
library(dplyr)

#save.image(file = "article title_debug_August_1st.RData")
load("article title_debug_August_1st.RData")


##Load Journal Graph

#90s
journal_graph = read.graph("journals-1990s.graphml", format = "graphml")
journal_graph

#2000s
journal_graph.2000 = read.graph("journals-2000s.graphml", format = "graphml")

#2010s
journal_graph.2010 = read.graph("journals-2010s.graphml", format = "graphml")

##Plot Journal_Graph
#plot(journal_graph, layout=layout_with_lgl, vertex.size=1, vertex.label.cex=0.2)

##Extract Main Componenent

#90s
main_component_graph = get_main_component(journal_graph)
main_component_graph



#2000s
main_component_graph.2000 = get_main_component(journal_graph.2000)

#2010s
main_component_graph.2010 = get_main_component(journal_graph.2010)

#Calculate average path length
av.90 = igraph::average.path.length(main_component_graph)
av.2000 = igraph::average.path.length(main_component_graph.2000)
av.2010 = igraph::average.path.length(main_component_graph.2010)

# Calculate Modularity
m.90 = igraph::modularity(main_component_graph,membership)
m.2000 = igraph::modularity(main_component_graph.2000)
m.2010 =igraph::modularity(main_component_graph.2010)

##Write GraphML - Main Component

write.graph(main_component_graph, "Main Component 1990s_August1st.graphml", format = "graphml")
##Plot Main Component Graph
#plot(main_component_graph, layout=layout_with_lgl, vertex.size=1, vertex.label.cex=0.2)

## Test Find Author
author_name.df =  get_authors_df.1(main_component_graph.2010)
max(author_name.df$membership)

find_author(journal_graph, "Pennebaker, James W.")
find_author(main_component_graph, "Pennebaker, James W.")

find_author(journal_graph, "Buss, David M.")
find_author(main_component_graph, "Buss, David M.")

## Test Find Author -2000s
find_author(journal_graph, "Costa, Paul T.")
find_author(main_component_graph, "Costa, Paul T.")

## Great Author DataFrame - By Community
author_name.df =  get_authors_df.1(main_component_graph.2010)
max(author_name.df$membership)

author_name.df.split = split(author_name.df$author_name,author_name.df$membership)
hope.3 = plyr::ldply(author_name.df.split, rbind)

# Write Author CSV file

write.csv(hope.3, "2010s Author and Community Labels - August 8th.csv")


##Get Author DF from Graph
Full_author_graph = get_authors_df_from_graph(main_component_graph)
max(Full_author_graph$membership)
nrow(Full_author_graph)

## Article Communities

df_article_communities = get.data.frame(main_component_graph, what="vertices")
df_article_communities = df_article_communities[df_article_communities$node_type=="article",]
df_article_communities = df_article_communities[c("doi", "title", "issn", "abstract", "membership","citedby_count","issn")]
df_article_communities$title = tolower(df_article_communities$title)
head(df_article_communities, n=1)
nrow(df_article_communities)


max(df_article_communities$membership)
names(df_article_communities)


##Testing for presence of expected articles

# This Article was present before - 90s
sum(df_article_communities$title == "authoritarianism of parents and offspring: intergenerational politics and adjustment to college")
sum(df_article_communities$title == "linguistic styles: language use as an individual difference")

#Articles that weren't present before - 90s
sum(df_article_communities$title == "construction of circumplex scales for the inventory of interpersonal problems")
sum(df_article_communities$title == "personality trait structure as a human universal")
sum(df_article_communities$title == "evaluating stability and change in personality and depression")
sum(df_article_communities$title == "on the accuracy of personality judgment: a realistic approach")
sum(df_article_communities$title == "the divided self: concurrent and longitudinal effects of psychological adjustment and social roles on self-concept differentiation")

sum(df_article_communities$title == "the temporal satisfaction with life scale")
sum(df_article_communities$title == "achievement goals and intrinsic motivation: a meta-analytic review")
sum(df_article_communities$title == "A Cognitive-Affective System Theory of Personality: Reconceptualizing Situations, Dispositions, Dynamics, and Invariance in Personality Structure")

##McCrae & Costa, 1990s
sum(df_article_communities$title == "personality trait structure as a human universal")
sum(df_article_communities$title == "an introduction to the five‐factor model and its applications")
sum(df_article_communities$title == "four ways five factors are basic")
sum(df_article_communities$title == "normal personality assessment in clinical practice: the neo personality inventory")
sum(df_article_communities$title == "domains and facets: hierarchical personality assessment using the revised neo personality inventory")
sum(df_article_communities$title == "facet scales for agreeableness and conscientiousness: a revision of tshe neo personality inventory")
sum(df_article_communities$title == "personality: another “hidden factor” in stress research")

## Compare SearchK DF with citation and Personality Network
nrow(df_article_communities)
names(df_article_communities)
gorder(main_component_graph)
main_component_graph
sum(V(main_component_graph)$node_type == "article")

V(subgraph(main_component_graph)$node_type == "article")

artcle.graph = V(main_component_graph)[main_component_graph$node_type == "article"]

V(journal_graph)[coauthorship_components$membership == biggest_component_id]


troubleshoot.cite = read.csv("troubleshooting authors and titles.csv")
tc.90 = read.csv("Top 5 cited from each community - 1990s.csv")
nrow(troubleshoot.cite)

sum(tc.90$title == "personality trait structure as a human universal")
sum(tc.90$title == "an introduction to the five‐factor model and its applicationss")
sum(tc.90$title == "four ways five factors are basic")
sum(tc.90$title == "normal personality assessment in clinical practice: the neo personality inventory")
sum(tc.90$title == "domains and facets: hierarchical personality assessment using the revised neo personality inventory")
sum(tc.90$title == "facet scales for agreeableness and conscientiousness: a revision of tshe neo personality inventory")
sum(tc.90$title == "personality: Another “Hidden Factor” in Stress Research")

##Rename DF
df_article_communities.lou = df_article_communities
max(df_article_communities.lou$membership)
names(df_article_communities.lou)

df_article_communities.lou.2000 = df_article_communities
max(df_article_communities.lou.2000$membership)
names(df_article_communities.lou.2000)

df_article_communities.lou.2010 = df_article_communities
max(df_article_communities.lou.2010$membership)
names(df_article_communities.lou.2010)

#Save environment for efficient labelling
#save.image(file = "article title_debug_August_1st.RData")

##Prep data for VosViewer
names(df_article_communities.lou)
nrow(df_article_communities.lou)
df_article_communities.lou$TandA = paste(df_article_communities.lou$title,df_article_communities.lou$abstract)

vData.1990 = df_article_communities.lou$TandA
vData.2010.T = df_article_communities.lou %>% select(title)

write.table(vData.1990, "vData2000s.June29th.txt")

##Write txt
write.table(vData, "vDataT.1990.Aplril8th.txt")

##Write CSV
write.csv(df_article_communities.lou, "Article Communities.csv")

##Insepct DATAFRAME
names()
min(df_article_communities.lou$membership)
max(df_article_communities.lou$membership)


## Find individual article communities
df_article_communities %>% filter(df_article_communities$title == "construction of circumplex scales for the inventory of interpersonal problems")
df_article_communities %>% filter(df_article_communities$title == "personality trait structure as a human universal")
df_article_communities %>% filter(df_article_communities$title == "evaluating stability and change in personality and depression")
df_article_communities %>% filter(df_article_communities$title == "on the accuracy of personality judgment: a realistic approach")
df_article_communities %>% filter(df_article_communities$title == "the divided self: concurrent and longitudinal effects of psychological adjustment and social roles on self-concept differentiation")
df_article_communities %>% filter(df_article_communities$title == "the temporal satisfaction with life scale")
df_article_communities %>% filter(df_article_communities$title == "on the motivational nature of cognitive dissonance: dissonance as psychological discomfort")


### 2000s - Major Article Test
nrow(df_article_communities)
sum(df_article_communities.lou.2000$title == "within-person variation in security of attachment: a self-determination theory perspective on attachment, need fulfillment, and well-being")
sum(df_article_communities.lou.2000$title == "self-regulation and the problem of human autonomy: does psychology need choice, self-determination, and will?")
sum(df_article_communities.lou.2000$title == "healthy and unhealthy emotion regulation: personality processes, individual differences, and life span development")
sum(df_article_communities.lou.2000$title == "the dark triad of personality: narcissism, machiavellianism, and psychopathy")
sum(df_article_communities.lou.2000$title == "gender differences in personality traits across cultures: robust and surprising findings")
sum(df_article_communities.lou.2000$title == "the power of personality: the comparative validity of personality traits, socioeconomic status, and cognitive ability for predicting important life outcomes")
sum(df_article_communities.lou.2000$title == "personality and the prediction of consequential outcomes")


sum(df_article_communities$title == "self-efficacy, values, and complementarity in dyadic interactions: integrating interpersonal and social-cognitive theory")


##2010s - Major Article Test
df_article_communities %>% filter(df_article_communities$title == "interpersonal dynamics in personality and personality disorders")
sum(df_article_communities$title == "interpersonal dynamics in personality and personality disorders")

##Select by community
df_article_communities %>% filter(df_article_communities$membership == "25")
