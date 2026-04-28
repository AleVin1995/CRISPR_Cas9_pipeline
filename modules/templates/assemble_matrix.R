library(tidyverse)

# Arguments
args <- commandArgs(trailingOnly = TRUE)

input_files <- str_split(args[1], ",")[[1]]
output_file <- args[2]

# Read all files and join them
final_df <- input_files %>%
    map(~read_tsv(.x, show_col_types = FALSE)) %>%
    reduce(inner_join)

# Save the result
write_tsv(final_df, output_file)