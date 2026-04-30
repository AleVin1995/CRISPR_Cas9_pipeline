#!/usr/bin/env Rscript

library(tidyverse)

# Arguments
opt <- list(
    input_matrix = "${lfc_sgrna_qc}",
    avg_col = "${params.avg_col}",
    output_file = "${params.lfc_gene_qc}"
)

input_matrix <- opt[['input_matrix']]
avg_col <- opt[['avg_col']]
output_file <- opt[['output_file']]

# Average the matrix by column
avg_df <- read_tsv(input_matrix, show_col_types = FALSE) %>%
    group_by_at(avg_col) %>%
    # Remove non-numeric columns before averaging
    select(where(is.numeric)) %>%
    summarise(across(everything(), mean, na.rm = TRUE))

# Save the result
write_tsv(avg_df, output_file)