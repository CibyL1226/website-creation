FROM rocker/shiny:latest

# Install required R packages
RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinydashboard', 'ggplot2', 'dplyr'), repos='https://cloud.r-project.org')"

# Copy the app files into the default Shiny app directory
COPY . /srv/shiny-server/

# Give proper permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose default port
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
