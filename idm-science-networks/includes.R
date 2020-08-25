# Ian Dennis Miller
# bibliometrics
# includes: load all libraries

source("R/utils/util.R")
source("R/utils/latex.R")

#unloadNamespace("lavaan")
#unloadNamespace("sem")

tmp_library_list = c(
    # JSON
    # "RJSONIO",
    # "rjson",

    # Database
    # "RPostgreSQL",
    # "DBI",

    # Data management
    # "RCurl",
    "data.table",
    "gdata",
    # "reshape",
    # "doBy",
    # "plyr",
    "stringr",

    # Process management
    # "doSNOW",
    # "foreach",

    # Model Search
    # "glmulti",
    # "rpart",
    # "rpart.plot",

    # Model Testing
    # "sem",
    # "lavaan",
    # "semTools",

    # Statistics
    # "QuantPsyc",
    # "multilevel",
    # "bstats",
    # "effects",
    # "e1071",
    # "memisc",
    # "psych",

    # Reporting
    "ggplot2",
    # "corrgram",
    # "xtable",
    "knitr",
    "kableExtra",
    "magick",
    # "i0",
    # "formula.tools",
    #"semPlot",

    "gtools",
    "intergraph",
    "igraph",
    "bibtex",
    "ggnetwork",
    "ggrepel",
    "network",
    "sna",
    "glasso",
    "qgraph"
)

load_libraries(tmp_library_list)

# source('http://openmx.psyc.virginia.edu/getOpenMx.R')
# install_prerequisites(tmp_library_list)
# devtools::install_github("briatte/ggnetwork")
# devtools::install_github('hadley/ggplot2')
# devtools::install_github('thomasp85/ggforce')
# devtools::install_github('thomasp85/ggraph')
