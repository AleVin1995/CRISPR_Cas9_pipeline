#!/usr/bin/env Rscript

library(CRISPRcleanR)
library(tidyverse)

# Arguments
opt <- list(
    auroc_thr = as.numeric("${params.auroc_thr}"),
    crispr_lib = "${params.crispr_lib}",
    fdr = as.numeric("${params.fdr}"),
    input_file = "${lfc_corr}",
    neg_ctrl_genes = basename("${params.neg_ctrl_genes}"),
    pos_ctrl_genes = basename("${params.pos_ctrl_genes}")
)

auroc_thr <- opt[['auroc_thr']]
crispr_lib <- opt[['crispr_lib']]
input_file <- opt[['input_file']]
neg_ctrl_genes <- opt[['neg_ctrl_genes']]
pos_ctrl_genes <- opt[['pos_ctrl_genes']]
fdr <- opt[['fdr']]

# Derive sample name and output file name from input file name
sample_name <- sub("_lfc_corr.tsv", "", basename(input_file))
output_file <- paste0(sample_name, "_lfc_corr_qc.tsv")

# Read the input
lfc_df <- read_tsv(input_file, show_col_types = FALSE)

pos_ctrl_genes <- read_tsv(pos_ctrl_genes, 
                           col_names = FALSE, 
                           show_col_types = FALSE) %>% 
    pull(1)
neg_ctrl_genes <- read_tsv(neg_ctrl_genes, 
                           col_names = FALSE, 
                           show_col_types = FALSE) %>% 
    pull(1)

# Load the CRISPR library
data(list = crispr_lib)
crispr_lib <- get(crispr_lib)

# Perform quality control
pos_ctrl_sgrnas <- ccr.genes2sgRNAs(crispr_lib, pos_ctrl_genes)
neg_ctrl_sgrnas <- ccr.genes2sgRNAs(crispr_lib, neg_ctrl_genes)

# Find the single _lfc column and compute AUROC
lfc_col <- grep("_lfc", colnames(lfc_df), value = TRUE)

if (length(lfc_col) != 1) {
    stop(paste0(
        "Expected exactly one _lfc column in ", basename(input_file),
        ", found ", length(lfc_col), ": ", paste(lfc_col, collapse = ", ")
    ))
}

lfc_values <- lfc_df[[lfc_col]]
names(lfc_values) <- lfc_df[["sgRNA"]]

auroc <- as.numeric(ccr.ROC_Curve(lfc_values, 
                       pos_ctrl_sgrnas, 
                       neg_ctrl_sgrnas,
                       FDRth = fdr)[["AUC"]])

# Check if the sample passes QC
if (auroc < auroc_thr) {
    warning(paste0("Sample ", sample_name, " has an AUROC of ", auroc, 
        " below the threshold of ", auroc_thr))
    write(sample_name, file = "low_qc_samples.log")
} else {
    write_tsv(lfc_df, output_file)
}