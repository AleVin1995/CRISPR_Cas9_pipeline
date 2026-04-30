#!/usr/bin/env Rscript

library(CRISPRcleanR)
library(tidyverse)

# Arguments
opt <- list(
    auroc_thr = as.numeric("${params.auroc_thr}"),
    crispr_lib = "${params.crispr_lib}",
    fdr = as.numeric("${params.fdr}"),
    input_matrix = "${lfc_sgrna_all}",
    neg_ctrl_genes = basename("${params.neg_ctrl_genes}"),
    output_file = "${params.lfc_sgrna_qc}",
    pos_ctrl_genes = basename("${params.pos_ctrl_genes}")
)

auroc_thr <- opt[['auroc_thr']]
crispr_lib <- opt[['crispr_lib']]
input_matrix <- opt[['input_matrix']]
neg_ctrl_genes <- opt[['neg_ctrl_genes']]
output_file <- opt[['output_file']]
pos_ctrl_genes <- opt[['pos_ctrl_genes']]
fdr <- opt[['fdr']]

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

# Load the CRISPR library
data(list = crispr_lib)
crispr_lib <- get(crispr_lib)

# Perform quality control
pos_ctrl_sgrnas <- ccr.genes2sgRNAs(crispr_lib, pos_ctrl_genes)
neg_ctrl_sgrnas <- ccr.genes2sgRNAs(crispr_lib, neg_ctrl_genes)

# Given the matrix, take recursively the lfc columns, keep the sgRNA as name and compute the AUROC for each column. If any column has an AUROC < auroc_thr, print a warning message.
qc_results <- lfc_df %>%
    select(starts_with("sgRNA"), starts_with("genes"), ends_with("_lfc")) %>%
    pivot_longer(cols = -c(sgRNA, genes), names_to = "sample", values_to = "lfc") %>%
    group_split(sample, .keep = TRUE) %>%
    map(~{
        sample_name <- unique(.x[["sample"]])
        lfc_values <- .x[["lfc"]]
        names(lfc_values) <- .x[["sgRNA"]]

        auroc <- as.numeric(ccr.ROC_Curve(lfc_values, 
                               pos_ctrl_sgrnas, 
                               neg_ctrl_sgrnas,
                               FDRth = fdr)[["AUC"]])

        return(.x %>% 
            mutate(auroc = auroc))
    }) %>%
    bind_rows()

# Check if any sample has an AUROC < auroc_thr
low_qc_samples <- qc_results %>%
    select(sample, auroc) %>%
    distinct() %>%
    filter(auroc < auroc_thr) %>%
    pull(sample) %>%
    str_remove("_lfc") %>%
    unique()

if (length(low_qc_samples) > 0) {
    warning(paste0("The following samples have an AUROC below the threshold of ", 
        auroc_thr, ": ", paste(low_qc_samples, collapse = ", ")))
    write(low_qc_samples, file = "low_qc_samples.log")
}

qc_results <- qc_results %>%
    filter(auroc >= auroc_thr) %>%
    pivot_wider(id_cols = c(sgRNA, genes), names_from = sample, values_from = lfc)

# Save the output
write_tsv(qc_results, output_file)