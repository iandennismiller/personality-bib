# Ian Dennis Miller
# bibliometrics
# support other operations

library(knitr)
library(rmarkdown)

####
# clean_env: remove everything from the environment except clean_ stuff

clean_env = function() {
  items = ls(envir=.GlobalEnv)
  filtered = items[grep('clean_', items, invert=TRUE)]
  rm(list=filtered, envir=.GlobalEnv)
}

####
# clean_tmp: remove any temporary variables

clean_tmp = function() {
  items = ls(envir=.GlobalEnv)
  filtered = items[grep('tmp_', items)]
  rm(list=filtered, envir=.GlobalEnv)
}

####
# abbreviate a variable name (or any string, for that matter)
# also keeps namespaces intact
# ex: abbr("long_name_blah.seddy_beedy.blah_and_all") -> "lnb.sb.baa"
# ex: abbr("long_name_blah_seddy_beedy_blah_and_all") -> "lnbsbbaa"

abbr = function(long_name) {
  long_name = as.character(long_name)
  short = character(0)
  first_letters = sapply(strsplit(strsplit(long_name, '\\.')[[1]], "_"), function(c){substr(c, 0, 1)})
  if (is.null(dim(first_letters))) {
    for (namespace in first_letters) {
      short = append(short, paste(namespace, collapse=""))
    }
    return(paste(short, collapse="."))
  }
  else {
    return(paste(first_letters, collapse=""))
  }
}

####
# liz's calculation of critical-r for a standardized coefficient
# ex: round(critical_r(df=6906, alpha=0.05), 3) -> 0.024
# thus, standardized coefficients above 0.024 (with df=6906) are significant at alpha=0.05

critical_r = function(df, alpha) {
  tmp_critical_t = qt(alpha/2, df, lower.tail=F)
  tmp_critical_r = sqrt( tmp_critical_t**2 / ((tmp_critical_t**2) + df) )
  return(tmp_critical_r)
}

install_prerequisites = function(library_list) {
  for (library_name in library_list) {
    install.packages(library_name, dependencies = TRUE)
  }
}

load_libraries = function(library_list) {
  for (library_name in library_list) {
    print(paste("load library", library_name))
    library(library_name, character.only=TRUE)
  }
}
