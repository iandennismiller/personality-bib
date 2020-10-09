# Ian Dennis Miller
# bibliometrics
# reports require this file; load data and set up models

try(clean_env())

rebuild_data = TRUE

if (rebuild_data) {
    source("idm-science-networks/includes.R")
    source("idm-science-networks/importing.R")
    source("idm-science-networks/scoring.R")
    save.image("data/canonical.RData.gz", compress=TRUE)
} else {
    load("data/canonical.RData.gz")
}
