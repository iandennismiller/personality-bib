# Ian Dennis Miller
# bibliometrics
# reports require this file; load data and set up models

try(clean_env())

rebuild_data = FALSE

if (rebuild_data) {
    source("R/includes.R")
    source("R/importing.R")
    source("R/scoring.R")
    save.image("data/canonical.RData.gz", compress=TRUE)
}
else {
    load("data/canonical.RData.gz")
}
