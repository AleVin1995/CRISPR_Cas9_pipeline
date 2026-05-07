#!/bin/bash
IMAGE_NAME="crispr_cas9_pipeline:v1.0"
TAR_FILE="crispr_pipeline_v1.tar.gz"
ARTICLE_ID="32159628"

# Check if data directory exists
# If it doesn't exist, download the data and prepare it for the pipeline
if [ ! -d "data/raw_sgrnas_counts" ] || [ ! -d "tests/data" ]; then
    echo "Raw sgrna counts directory not found. Downloading and preparing data..."

    curl -s "https://api.figshare.com/v2/articles/$ARTICLE_ID" | \
    jq -r '.files[].download_url' | \
    xargs -n 1 curl -LJO

    tar -xzvf raw_sgrnas_counts.tar.gz && mv raw_sgrnas_counts data/
    tar -xzvf test_data.tar.gz && mv test_data tests/ && \
        mv tests/test_data tests/data

    rm raw_sgrnas_counts.tar.gz test_data.tar.gz
fi

# Check if image exists locally
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Image not found."
    
    if [ -f "$TAR_FILE" ]; then
        echo "Loading image from $TAR_FILE..."
        docker load -i $TAR_FILE
    elif [ -f "Dockerfile" ]; then
        echo "Building image from Dockerfile..."
        docker build -t $IMAGE_NAME .
    else
        echo "Error: No image, tar file, or Dockerfile found!"
        exit 1
    fi
fi

# Run the pipeline
nextflow run workflows/main.nf -profile docker
