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

## setup R from within-R
COPY github-pkg.txt /

RUN nice R -q -e 'remotes::install_github(readLines("/github-pkg.txt"))'

RUN su rstudio -c "git clone https://github.com/r-lib/revdepcheck /home/rstudio/revdepcheck"

## last-minute changes
RUN apt-get install -y \
  rsync

RUN mkdir -p /opt/cran/src/contrib/ && rsync -dtlzv --delete cran.r-project.org::CRAN/src/contrib/ /opt/cran/src/contrib/

RUN \
  apt-get upgrade -y

RUN \
  apt-get install -y \
  cifs-utils unscd libxml2-dev xvfb git-sh lbzip2 libfftw3-dev libgdal-dev libgeos-dev libgsl0-dev libgl1-mesa-dev libglu1-mesa-dev libhdf4-alt-dev libhdf5-dev liblwgeom-dev libproj-dev libprotobuf-dev libnetcdf-dev libsqlite3-dev libudunits2-dev netcdf-bin protobuf-compiler tk-dev unixodbc-dev icedtea-netx libgdal-dev libproj-dev libgeos-dev libgsl-dev librsvg2-dev libxcb1-dev libxdmcp-dev libxslt1-dev libxt-dev mdbtools netcdf-bin libmagick++-dev libsndfile1-dev libv8-dev libsecret-1-dev libzmq3-dev openjdk-8-jdk-headless libgtk2.0-dev libmagic-dev libmpich-dev libgmp-dev librdf0-dev ggobi libpoppler-cpp-dev jags libglpk-dev python-dev libmpfr-dev libapparmor-dev libjq-dev libtesseract-dev libleptonica-dev libprotoc-dev libsodium-dev mpi-default-dev tesseract-ocr-eng librrd-dev cargo coinor-symphony libgit2-dev coinor-libsymphony-dev coinor-libcgl-dev autotools-dev libsbml-dev libopenbabel-dev libgeos++-dev libssh-dev pandoc pandoc-citeproc iotop libssl1.0-dev libsasl2-dev cmake libqt4-dev libquantlib0-dev bwidget mailutils

RUN \
  echo 'options(repos = "file:///opt/cran")' >> /usr/local/lib/R/etc/Rprofile.site

RUN su rstudio -c "git clone https://github.com/krlmlr/scriptlets /home/rstudio/scriptlets && cd scriptlets && make"

RUN chsh -s /bin/bash rstudio
