#!/bin/bash
IMAGE_NAME="crispr_cas9_pipeline:v1.0"
TAR_FILE="crispr_pipeline_v1.tar.gz"

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
nextflow run main.nf
