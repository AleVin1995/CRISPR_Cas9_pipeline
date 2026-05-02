#!/usr/bin/env Rscript

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 4) {
    stop("Usage: design_matrix_mageck.R <count_matrix.tsv> <default_n_cols_sgrna> <min_treatments> <n_controls>")
}

opt <- list(
    cell_line = args[[1]],
    default_n_cols_sgrna = args[[2]],
    min_treatments = args[[3]],
    n_controls = args[[4]]
)

cell_line <- opt[['cell_line']]
cell_line_basename <- sub("[.].+", "", basename(cell_line))

default_n_cols_sgrna <- as.integer(opt[['default_n_cols_sgrna']])
min_treatments <- as.integer(opt[['min_treatments']])
n_controls <- as.integer(opt[['n_controls']])

# Read the input matrix
df <- read_tsv(cell_line, show_col_types = FALSE)
procede <- TRUE

# Check that the number of columns is sufficient
# for the specified number of controls
if (ncol(df) < default_n_cols_sgrna + n_controls) {
    warning(paste0("Warning: The input matrix has ", ncol(df),
        " columns, which is less than the required ",
        default_n_cols_sgrna + n_controls, " 
        columns for the specified number of controls."))
    procede <- FALSE
}

# Check that there are enough treatment samples
n_treatments <- ncol(df) - default_n_cols_sgrna - n_controls

if (n_treatments < min_treatments) {
    warning(paste0("Warning: The input matrix has ", n_treatments,
        " treatment samples, which is less than the required ",
        min_treatments, " treatment samples."))
    procede <- FALSE
}

# Create the design matrix
if (procede) {
    design_matrix <- data.frame(
        samples = colnames(df)[(default_n_cols_sgrna + 1):ncol(df)],
        baseline = rep(1, ncol(df) - default_n_cols_sgrna),
        # get cell line name as column name
        cell_line = c(rep(0, n_controls), rep(1, n_treatments))
    ) %>%
        rename(!!paste0(cell_line_basename, "_cell_line") := cell_line)

    # Save the design matrix to a temporary file
    write.table(design_matrix, file = "", sep = "\t",
        row.names = FALSE, quote = FALSE)
}