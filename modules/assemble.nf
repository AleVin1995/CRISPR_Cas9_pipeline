process ASSEMBLE_MATRIX {
    tag "${input_dir.name}"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path input_dir // directory containing batch of sgRNA counts

    output:
    path "raw_sgrna_counts_${input_dir.name}.tsv"

    script:
    """
    #!/usr/bin/env Rscript
    library(tidyverse)

    count_files <- list.files("${input_dir}", full.names = TRUE)

    # Identify the plasmid column
    count_data_sub <- lapply(count_files[1:2], read_tsv)

    col_file1 <- colnames(count_data_sub[[1]])
    col_file2 <- colnames(count_data_sub[[2]])

    ncol_file1 <- length(col_file1)
    ncol_file2 <- length(col_file2)

    plasmid_col <- intersect(col_file1[3:ncol_file1], col_file2[3:ncol_file2])

    # Check if a common plasmid column was found
    if (length(plasmid_col) == 0) {
        stop("No common plasmid column found in the input files.")
    } else {
        # Replace the plasmid column name with "plasmid" across all files
        # Replace the treatment column with the file name (without extension) across all files
        count_data <- lapply(count_files, function(file) {
            data <- read_tsv(file)
            colnames(data)[colnames(data) == plasmid_col] <- "plasmid"

            treatment_name <- basename(file) %>%
                strsplit("\\\\.") %>%
                .[[1]] %>%
                .[1]
            
            treatment_col <- setdiff(colnames(data)[3:ncol(data)], "plasmid")

            colnames(data)[colnames(data) %in% treatment_col] <- treatment_name

            return(data)
        })

        merged_data <- count_data %>%
            reduce(inner_join) %>%
            select(1:2, plasmid, everything())
        
        # Write the merged data to a TSV file
        write_tsv(merged_data, "raw_sgrna_counts_${input_dir.name}.tsv")
    }
    """
}