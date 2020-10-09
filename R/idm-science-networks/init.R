# Ian Dennis Miller
# bibliometrics
# reports require this file; load data and set up models

try(clean_env())

rebuild_data = FALSE

if (rebuild_data) {
    source("R/idm-science-networks/includes.R")
    source("R/idm-science-networks/importing.R")
    source("R/idm-science-networks/scoring.R")
    save.image("data/canonical.RData.gz", compress=TRUE)
} else {
    load("data/canonical.RData.gz")
}
