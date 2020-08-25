# Ian Dennis Miller
# bibliometrics
# importing: responsible for loading all the raw, non-canonical data sources

# assume getwd() == project root, not /R or /report
citations = read.bib("data/bibliography.bib")

clean_tmp()
