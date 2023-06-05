FROM rocker/shiny:4.1.0

# Installing packages needed for check traffic on the container and kill if none
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -qq update && apt-get install --no-install-recommends -y net-tools procps libgdal-dev libproj-dev && \
# Installing R package dedicated to the shniy app
    Rscript -e "install.packages('leaflet')" && \
    Rscript -e "install.packages('stringr')" && \
    Rscript -e "install.packages('dplyr')" && \
    Rscript -e "install.packages('xml2')" && \
    Rscript -e "install.packages('metadig')" && \
    Rscript -e "install.packages('ggplot2')" && \
## Additional dependencies not listed originally
    Rscript -e "install.packages('ragtop')" && \
    Rscript -e "install.packages('rdrop2')" && \
    Rscript -e "install.packages('broman')"

# Bash script to check traffic
COPY META /srv/shiny-server/sample-apps/META/
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod 777 /usr/bin/shiny-server.sh
CMD ["/usr/bin/shiny-server.sh"]
