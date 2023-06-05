FROM rocker/shiny:4.1.0

# Installing packages needed for check traffic on the container and kill if none
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -qq update && apt-get install --no-install-recommends -y net-tools procps libgdal-dev libproj-dev libxslt1-dev
# Installing R package dedicated to the shniy app
RUN    Rscript -e "install.packages('leaflet')" && \
    Rscript -e "install.packages('remotes')" && \
    Rscript -e "install.packages('stringr')" && \
    Rscript -e "install.packages('dplyr')" && \
    Rscript -e "install.packages('xml2')" && \
    Rscript -e "remotes::install_github('NCEAS/metadig-r')" && \
    Rscript -e "install.packages('ggplot2')" && \
## Additional dependencies not listed originally
    Rscript -e "install.packages('ragtop')" && \
    Rscript -e "install.packages('rdrop2')" && \
    Rscript -e "install.packages('broman')"

RUN    Rscript -e "install.packages('DT')"
RUN    Rscript -e "install.packages('xslt')"
RUN    Rscript -e "install.packages('gdata')"
RUN    Rscript -e "install.packages('shinycssloaders')"
RUN    Rscript -e "install.packages('rmarkdown')"


# Bash script to check traffic
COPY metaCure-main /srv/shiny-server/sample-apps/META/
RUN chmod -R 777  /srv/shiny-server/sample-apps/META
RUN chmod -R 777  /opt/shiny-server/samples/sample-apps/META
COPY shiny-server.sh /usr/bin/shiny-server.sh
CMD ["/usr/bin/shiny-server.sh"]


