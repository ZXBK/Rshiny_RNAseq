############################################################ 
# Dockerfile to build container with shiny server to run
# Based on r-base 
############################################################ 

FROM rocker/rstudio:4.3.1

# File Author / Maintainer
MAINTAINER Benjamin Kao <benjamin@agenbox.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libboost-all-dev libsodium-dev libxtst6 libpng-dev libxml2-dev libz-dev libfontconfig1-dev libglpk-dev \
    wget gdebi-core

RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# CRAN packages
RUN    R -e "install.packages('https://cran.rstudio.com/src/contrib/ggfun_0.1.3.tar.gz')"
RUN    R -e "install.packages('https://cran.r-project.org/src/contrib/aplot_0.2.1.tar.gz')"
RUN    R -e "install.packages(c('shiny','shinyjs','shinyBS','plotly','matrixStats','XML','xml2','DT','reactlog','crosstalk','ggrepel','systemfonts','ggforce','ggraph','scatterpie','ggridges','forcats','colourpicker','GOplot','glue'))"

# BioconductoR packages
RUN    R -e "install.packages('BiocManager')"
RUN    R -e "BiocManager::install(c('DESeq2','BiocGenerics','org.Hs.eg.db','enrichplot','pathview','pheatmap','biomaRt','enrichplot','clusterProfiler'))"

RUN rm -rf /srv/shiny-server

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY APP /srv/shiny-server/
RUN chown shiny:shiny /var/lib/shiny-server  /usr/local/lib/R/site-library
#https://github.com/rocker-org/shiny/issues/49

USER shiny

WORKDIR /srv/shiny-server

EXPOSE 5000

CMD /usr/bin/shiny-server

