#!/usr/bin/env Rscript

library(CoRe)
library(tidyverse)

# Arguments
opt <- list(
    input_matrix = "${lfc_gene_qc}",
    neg_ctrl_genes = "${neg_ctrl_genes}",
    output_file = "${params.gene_class}",
    pos_ctrl_genes = "${pos_ctrl_genes}"
)

input_matrix <- opt[['input_matrix']]
neg_ctrl_genes <- opt[['neg_ctrl_genes']]
output_file <- opt[['output_file']]
pos_ctrl_genes <- opt[['pos_ctrl_genes']]

# Read the input
lfc_df <- read_tsv(input_matrix, show_col_types = FALSE)
pos_ctrl_genes <- read_tsv(pos_ctrl_genes,
                           col_names = FALSE,
                           show_col_types = FALSE) %>%
    pull(1)
neg_ctrl_genes <- read_tsv(neg_ctrl_genes,
                           col_names = FALSE,
                           show_col_types = FALSE) %>%
    pull(1)

# Scale the matrix by gene
lfc_scaled <- lfc_df %>%
    column_to_rownames("genes") %>%
    CoRe.scale_to_essentials(
        ., 
        pos_ctrl_genes, 
        neg_ctrl_genes
    )

# Binarize the matrix
lfc_binary <- CoRe.Binarize_Matrix(
    lfc_scaled,
    method = "fdr",
    ess_genes = pos_ctrl_genes, 
    noness_genes = neg_ctrl_genes,
    scaled = FALSE,
    FDRth = 0.05
)

# Get the context-specific and core-essential genes
noness_genes <- names(which(rowSums(lfc_binary) == 0))

core_fitness_genes <- CoRe.FiPer(
    lfc_scaled,
    method = "AUC"
)[["cfgenes"]]

context_specific_genes <- setdiff(
    rownames(lfc_binary),
    union(core_fitness_genes, noness_genes)
)

# Create a data frame with the results
result_df <- data.frame(
    gene = rownames(lfc_binary),
    type = case_when(
        rownames(lfc_binary) %in% core_fitness_genes ~ "core",
        rownames(lfc_binary) %in% context_specific_genes ~ "context",
        rownames(lfc_binary) %in% noness_genes ~ "noness",
        TRUE ~ "unclassified"
    )
)

# Save the results
write_tsv(result_df, output_file)