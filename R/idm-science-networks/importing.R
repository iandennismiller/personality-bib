# Ian Dennis Miller
# bibliometrics
# importing: responsible for loading all the raw, non-canonical data sources

# assume getwd() == project root, not /R or /report
# citations = read.bib("data/bibliography.bib")
citations = read.bib("python/JPSP_a.bib")

clean_tmp()
