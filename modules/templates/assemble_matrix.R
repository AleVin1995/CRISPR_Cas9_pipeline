#!/usr/bin/env Rscript

library(tidyverse)

# Arguments
opt <- list(
    input_files = strsplit("${lfc_corr_files.join(',')}", ",")[[1]],
    join_cols = strsplit("${params.join_cols.join(',')}", ",")[[1]],
    drop_cols = strsplit("${params.drop_cols.join(',')}", ",")[[1]],
    output_file = "${params.lfc_sgrna_all}"
)

input_files <- opt[['input_files']]
join_cols <- opt[['join_cols']]
drop_cols <- opt[['drop_cols']]
output_file <- opt[['output_file']]

# Read all files and join them on invariant annotation columns
all_df <- input_files %>%
    map(~read_tsv(.x, show_col_types = FALSE) %>%
    select(-any_of(drop_cols))) %>%
    reduce(full_join, by = join_cols)

# Save the result
write_tsv(all_df, output_file)