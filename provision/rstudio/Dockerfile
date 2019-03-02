FROM rocker/geospatial:latest

## install tools and deps
## allow sudo for rstudio user
RUN apt-get install -y \
  curl \
  gnupg \
  libpoppler-cpp-dev \
  apt-transport-https \
  sudo && \
  adduser rstudio sudo

# update after adding apt repositories
RUN apt-get update -q

## setup R from within-R
COPY cran-pkg.txt /

RUN nice R -q -e 'pkg <- readLines("/cran-pkg.txt"); missing <- setdiff(pkg, rownames(installed.packages())); install.packages(missing, repos="https://cran.r-project.org", Ncpus = parallel::detectCores())'

RUN nice R -q -e 'pkg <- readLines("/cran-pkg.txt"); missing <- setdiff(pkg, rownames(installed.packages())); print(missing); stopifnot(length(missing) == 0)'

## last-minute changes
RUN apt-get install -y \
  screen tree locate

RUN updatedb

RUN \
  tlmgr update --self && \
  tlmgr install sectsty && \
  tlmgr update --all

RUN nice R -q -e 'remotes::install_github(readLines("/github-pkg.txt"))'

RUN su rstudio git clone https://github.com/r-lib/revdepcheck /home/rstudio/revdepcheck
