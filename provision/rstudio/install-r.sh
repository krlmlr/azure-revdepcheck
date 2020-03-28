#!/bin/sh

R -q -e 'install.packages("remotes")'

R -q -e 'cores <- parallel::detectCores(); Sys.setenv(MAKEFLAGS = paste0("-j ", cores)); remotes::install_github("r-lib/crancache")'

R -q -e 'cores <- parallel::detectCores(); Sys.setenv(MAKEFLAGS = paste0("-j ", cores)); pkg <- readLines("/cran-pkg.txt"); missing <- setdiff(pkg, rownames(installed.packages())); crancache::install_packages(missing, repos="https://cran.r-project.org")'

R -q -e 'pkg <- readLines("/cran-pkg.txt"); missing <- setdiff(pkg, rownames(installed.packages())); print(missing); stopifnot(length(missing) == 0)'

R -q -e 'cores <- parallel::detectCores(); Sys.setenv(MAKEFLAGS = paste0("-j ", cores)); remotes::install_github(readLines("/github-pkg.txt"))'
