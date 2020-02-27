FROM rocker/geospatial:latest

## Use bash as shell for RStudio
RUN chsh -s /bin/bash rstudio

# update after adding apt repositories
RUN apt-get update -q && apt-get upgrade -y -q

## install tools and deps
## allow sudo for rstudio user
RUN apt-get install -y \
  curl \
  gnupg \
  libpoppler-cpp-dev \
  apt-transport-https \
  screen tree locate \
  rsync \
  cifs-utils unscd libxml2-dev xvfb lbzip2 libfftw3-dev libgdal-dev libgeos-dev libgl1-mesa-dev libglu1-mesa-dev libhdf4-alt-dev libhdf5-dev liblwgeom-dev libproj-dev libprotobuf-dev libnetcdf-dev libsqlite3-dev libudunits2-dev netcdf-bin protobuf-compiler tk-dev unixodbc-dev icedtea-netx libgdal-dev libproj-dev libgeos-dev libgsl-dev librsvg2-dev libxcb1-dev libxdmcp-dev libxslt1-dev libxt-dev mdbtools netcdf-bin libmagick++-dev libsndfile1-dev libnode-dev libsecret-1-dev libzmq3-dev libgtk2.0-dev libmagic-dev libmpich-dev libgmp-dev librdf0-dev ggobi libpoppler-cpp-dev jags libglpk-dev python-dev libmpfr-dev libapparmor-dev libjq-dev libtesseract-dev libleptonica-dev libprotoc-dev libsodium-dev mpi-default-dev tesseract-ocr-eng librrd-dev cargo coinor-symphony libgit2-dev coinor-libsymphony-dev coinor-libcgl-dev autotools-dev libsbml5-dev libopenbabel-dev libgeos++-dev libssh-dev pandoc pandoc-citeproc iotop libssl-dev libsasl2-dev cmake libqt4-dev libquantlib0-dev bwidget mailutils \
  sudo && \
  adduser rstudio sudo

## setup R from within-R
RUN R CMD javareconf

## setup R from within-R
COPY cran-pkg.txt /

RUN nice R -q -e 'cores <- parallel::detectCores(); Sys.setenv(MAKEFLAGS = paste0("-j ", cores)); pkg <- readLines("/cran-pkg.txt"); missing <- setdiff(pkg, rownames(installed.packages())); install.packages(missing, repos="https://cran.r-project.org", Ncpus = cores)'

RUN nice R -q -e 'cores <- parallel::detectCores(); Sys.setenv(MAKEFLAGS = paste0("-j ", cores)); pkg <- readLines("/cran-pkg.txt"); missing <- setdiff(pkg, rownames(installed.packages())); print(missing); stopifnot(length(missing) == 0)'

## Install packages from GitHub
COPY github-pkg.txt /

RUN nice R -q -e 'cores <- parallel::detectCores(); Sys.setenv(MAKEFLAGS = paste0("-j ", cores)); remotes::install_github(readLines("/github-pkg.txt"))'

## TeXlive package
RUN \
  tlmgr update --self && \
  tlmgr install sectsty && \
  tlmgr update --all

## Clone revdepchecks and scriptlets
RUN su rstudio -c "cd && pwd && git clone https://github.com/r-lib/revdepcheck && git clone https://github.com/krlmlr/scriptlets && cd scriptlets && make"

## File database
RUN updatedb
