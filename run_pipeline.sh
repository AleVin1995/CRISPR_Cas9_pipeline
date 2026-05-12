#!/bin/bash

# Run the pipeline with pixi environment
nextflow run workflows/main.nf -profile pixi

# Run the pipeline with docker environment
# nextflow run workflows/main.nf -profile docker