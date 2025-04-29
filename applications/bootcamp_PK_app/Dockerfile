FROM rocker/shiny:latest

# Install mrgsolve dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    libclang-dev libboost-all-dev cmake

# Install R packages including mrgsolve
RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinydashboard', 'ggplot2', 'dplyr', 'mrgsolve', 'DT'), repos='https://cloud.r-project.org')"

COPY . /srv/shiny-server/
RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
