#!/usr/bin/env Rscript

library(CRISPRcleanR)
library(tidyverse)

# Arguments
opt <- list(
    cell_line            = "${input_file}",
    crispr_lib           = "${params.crispr_lib}",
    min_reads            = as.numeric("${params.min_reads}"),
    n_controls           = as.numeric("${params.n_controls}"),
    scaling_method       = "${params.scaling_method}",
    min_treatments       = as.numeric("${params.min_treatments}"),
    default_n_cols_sgrna = as.numeric("${params.default_n_cols_sgrna}")
)

cell_line            <- opt[['cell_line']]
crispr_lib           <- opt[['crispr_lib']]
min_reads            <- opt[['min_reads']]
n_controls           <- opt[['n_controls']]
scaling_method       <- opt[['scaling_method']]
min_treatments       <- opt[['min_treatments']]
default_n_cols_sgrna <- opt[['default_n_cols_sgrna']]

cell_line_basename <- sub("[.].+", "", basename(cell_line))

# Load the CRISPR library
data(list = crispr_lib)
crispr_lib <- get(crispr_lib)

# Normalize and compute log fold changes
norm_and_lfc <- ccr.NormfoldChanges(cell_line,
                                    min_reads = min_reads,
                                    libraryAnnotation = crispr_lib,
                                    ncontrols = n_controls,
                                    method = scaling_method)

# If number of treatment samples is < min_treatments, abort the workflow
n_treatment_samples <- ncol(norm_and_lfc[['norm_counts']]) - n_controls - default_n_cols_sgrna

if (n_treatment_samples < min_treatments) {
    warning(paste0("At least two treatment samples are required to compute log fold changes for ",
        cell_line_basename, ". Skipping."))
} else {
    # Genome sorting
    sorted_genome <- ccr.logFCs2chromPos(norm_and_lfc[['logFCs']], crispr_lib) %>%
        rownames_to_column("sgRNA")
    
    # Bias correction
    corrected_lfc_res <- ccr.GWclean(sorted_genome)
    corrected_lfc <- corrected_lfc_res[["corrected_logFCs"]] %>%      
        # Rename correctedFC to cell line specific name
        rename(!!paste0(cell_line_basename, "_lfc") := correctedFC)

    # Save files
    output_file <- paste0(cell_line_basename, "_lfc_corr.tsv")

    write.table(corrected_lfc, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
    write.table(norm_and_lfc[['norm_counts']], file = paste0(cell_line_basename, "_count_norm.tsv"), 
        sep = "\t", row.names = FALSE, quote = FALSE)
}