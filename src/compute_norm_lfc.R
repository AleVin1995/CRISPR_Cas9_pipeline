library(CRISPRcleanR)
library(tidyverse)

# Arguments
args <- commandArgs(trailingOnly = TRUE)

cell_line <- args[1]
crispr_lib <- args[2]
min_reads <- as.numeric(args[3])
n_controls <- as.numeric(args[4])
scaling_method <- args[5]

cell_line_basename <- basename(cell_line) %>%
    str_split_fixed("\\.", 2) %>%
    .[, 1]

# Load the CRISPR library
data(list = crispr_lib, character.only = TRUE)
crispr_lib <- get(crispr_lib)

# Normalize and compute log fold changes
norm_and_lfc <- ccr.NormfoldChanges(cell_line,
                                    min_reads = min_reads,
                                    libraryAnnotation = crispr_lib,
                                    ncontrols = n_controls,
                                    method = scaling_method)

# If number of treatment samples is < 2, abort the workflow
n_treatment_samples <- ncol(norm_and_lfc$norm_counts) - n_controls - 2

if (n_treatment_samples < 2) {
    # Insert the cell line name into the error message
    stop(paste0("At least two treatment samples are required to compute log fold changes for ", 
        cell_line_basename, ". Aborting workflow."))
} else {
    # Genome sorting
    sorted_genome <- ccr.logFCs2chromPos(norm_and_lfc$logFCs, crispr_lib) %>%
        rownames_to_column("sgRNA") %>%
        # Rename avgFC to cell line specific name
        rename(!!paste0(cell_line_basename, "_avgFC") := avgFC)

    # Save files
    output_file <- paste0(cell_line_basename, "_norm_lfc.tsv")

    write.table(sorted_genome, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
    write.table(norm_and_lfc$norm_counts, file = paste0(cell_line_basename, "_norm_counts.tsv"), 
        sep = "\t", row.names = FALSE, quote = FALSE)
}