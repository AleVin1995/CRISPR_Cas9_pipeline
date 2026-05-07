# CRISPR-Cas9 Screening Analysis Pipeline

## Introduction

This pipeline performs end-to-end analysis of pooled CRISPR-Cas9 loss-of-function screens based on the methodology described in [1]. Starting from raw sgRNA count matrices, it computes corrected log fold changes (LFCs), applies quality control filters, and identifies essential genes through multiple scoring methods. The pipeline is built with [Nextflow](https://www.nextflow.io) DSL2 and runs inside a Docker container, making it portable and reproducible across computing environments.

[1] Behan F.M. et al. [*Prioritization of cancer therapeutic targets using CRISPR-Cas9 screens.*](https://doi.org/10.1038/s41586-019-1103-9) Nature, 2019.

---

## Pipeline Summary

1. **Bias correction** — Computes per-sample log fold changes from raw sgRNA counts and corrects for copy-number bias using CRISPRcleanR (one job per cell line per batch).
2. **Quality control** — Filters samples by AUROC score computed against positive (essential) and negative (non-essential) control gene sets; samples below the threshold are excluded.
3. **Matrix assembly (LFC)** — Merges all QC-passed, bias-corrected sgRNA LFC files into a single matrix.
4. **MAGeCK MLE** *(optional)* — Runs MAGeCK maximum-likelihood estimation on each QC-passed batch to produce gene-level selection scores.
5. **BAGEL2** *(optional)* — Runs BAGEL2 Bayes factor analysis on each QC-passed LFC file to score gene essentiality.
6. **Matrix assembly (MAGeCK / BAGEL2)** — Assembles per-sample MAGeCK and/or BAGEL2 output files into genome-wide matrices.
7. **LFC averaging** — Averages sgRNA-level LFCs to produce gene-level LFC estimates.
8. **Gene classification** — Classifies genes as essential, non-essential, or context-specific based on their dependency scores across all samples.

---

## Usage

### Requirements

- [Docker](https://www.docker.com/) (recommended) or a local Singularity/Conda environment
- [Nextflow](https://www.nextflow.io/) ≥ 23.10

### Quick start

```bash
bash run_pipeline.sh
```

The script automatically loads or builds the Docker image (`crispr_cas9_pipeline:v1.0`) and then executes the pipeline with the Docker profile:

```bash
nextflow run workflows/main.nf -profile docker
```

### Custom run

Example command to run the pipeline with custom parameters:

```bash
nextflow run workflows/main.nf \
    -profile docker \
    --input_batches "data/raw_sgrnas_counts/*" \
    --outdir results/ \
    --crispr_lib KY_Library_v1.0 \
    --pos_ctrl_genes bagel/CEGv2.txt \
    --neg_ctrl_genes bagel/NEGv1.txt \
    --bagel_run true \
    --mageck_run true
```
