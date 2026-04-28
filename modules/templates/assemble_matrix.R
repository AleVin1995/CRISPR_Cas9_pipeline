#!/usr/bin/env Rscript

library(tidyverse)

# Arguments
opt <- list(
    input_files = strsplit("${norm_lfc_files.join(',')}", ",")[[1]],
    output_file = "${params.sgrna_norm_lfc_assembled}"
)

input_files <- opt[['input_files']]
output_file <- opt[['output_file']]

# Read all files and join them
final_df <- input_files %>%
    map(~read_tsv(.x, show_col_types = FALSE)) %>%
    reduce(inner_join)

# Save the result
write_tsv(final_df, output_file)