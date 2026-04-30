#!/usr/bin/env Rscript

library(tidyverse)

# Arguments
opt <- list(
    input_matrix = "${sgrna_norm_lfc_assembled}",
    avg_col = "${params.avg_col}",
    drop_cols = "${params.drop_cols.join(',')}",
    output_file = "${params.gene_norm_lfc_assembled}"
)

input_matrix <- opt[['input_matrix']]
avg_col <- opt[['avg_col']]
drop_cols <- strsplit(opt[['drop_cols']], ",")[[1]]
output_file <- opt[['output_file']]

# Average the matrix by column
avg_df <- read_tsv(input_matrix, show_col_types = FALSE) %>%
    group_by_at(avg_col) %>%
    summarise(across(everything(), mean, na.rm = TRUE)) %>%
    select(-any_of(drop_cols))

# Save the result
write_tsv(avg_df, output_file)