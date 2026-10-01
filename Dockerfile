FROM rocker/r-ver:4.5.3

# Install required Linux dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    cmake \
    libx11-dev \
    pandoc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('DBI', 'RPostgres', 'paws.storage'), repos='https://cloud.r-project.org')"

WORKDIR /app

COPY s3_to_rds.R /app/s3_to_rds.R

CMD ["Rscript", "s3_to_rds.R"]
