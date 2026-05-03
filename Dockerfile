# Use a stable Debian base
FROM debian:bookworm-slim

# Install system dependencies for Pixi and R package compilation
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    build-essential \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Pixi
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:$PATH"

WORKDIR /app

# Initialize Pixi and add channels
RUN pixi init . && \
    pixi project channel add conda-forge && \
    pixi project channel add bioconda

# Install all requested Conda/Bioconda dependencies
RUN pixi add \
    "python>=3.12.13,<3.13" \
    "pip>=26.0.1,<27" \
    "r-base>=4.5.3,<4.6" \
    "mageck>=0.5.9.5,<0.6" \
    "r-tidyverse>=2.0.0,<3" \
    "r-devtools>=2.5.1,<3" \
    "r-remotes>=2.5.0,<3" \
    "bioconductor-shortread>=1.68.0,<2" \
    "bioconductor-biostrings>=2.78.0,<3" \
    "bioconductor-rsubread>=2.24.0,<3" \
    "bioconductor-genomicalignments>=1.46.0,<2" \
    "bioconductor-rqc>=1.44.0,<2" \
    "bioconductor-rsamtools>=2.26.0,<3" \
    "click>=8.3.3,<9" \
    "numpy>=2.4.3,<3" \
    "pandas>=3.0.2,<4" \
    "scipy>=1.17.1,<2" \
    "scikit-learn>=1.8.0,<2" \
    "openssl>=3.2.0"

# Install GitHub R packages using the Pixi-managed R environment
# We use 'pixi run' to ensure the packages are installed into the correct library
RUN pixi run Rscript -e 'pak::pak("francescojm/CRISPRcleanR", upgrade="FALSE")' && \
    pixi run Rscript -e 'pak::pak("DepMap-Analytics/CoRe", upgrade="FALSE")'

# Make the environment accessible by default
ENV PATH="/app/.pixi/envs/default/bin:$PATH"

# Default command
CMD ["bash"]