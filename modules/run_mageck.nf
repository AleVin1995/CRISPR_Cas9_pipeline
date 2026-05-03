process RUN_MAGECK {
    tag "${batch_name}/${input_file.name}"
    maxForks 1
    cpus 4

    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.mageck_dir}", mode: 'copy', pattern: "*.mageck.gene_summary*"

    input:
    tuple val(batch_name), path(input_file)

    output:
    path "*.mageck.gene_summary*", emit: mageck, optional: true

    script:
    """
    # Replace anything after "." or "_"
    cell_line_basename=${input_file.baseName}
    cell_line_basename=\${cell_line_basename%%[._]*}

    gunzip -c ${input_file} > \${cell_line_basename}.tsv

    design_matrix_file=\${cell_line_basename}_design_matrix.tsv

    # Generate the design matrix for MAGeCK
    if Rscript ${projectDir}/../modules/templates/design_matrix_mageck.R \
        \${cell_line_basename}.tsv \
        ${params.default_n_cols_sgrna} \
        ${params.min_treatments} \
        ${params.n_controls} \
        > \${design_matrix_file} && [ -s \${design_matrix_file} ]; then

        # Run MAGeCK MLE only if the design matrix was generated and non-empty
        mageck mle -k \${cell_line_basename}.tsv \
            -d \${design_matrix_file} \
            -n \${cell_line_basename}.mageck \
            --no-permutation-by-group \
            --threads ${task.cpus}

        # Subset the gene summary file to keep only the relevant columns
        awk -v col=${params.mageck_col} 'NR==1 {for(i=1;i<=NF;i++) if(\$i == "|" col) target=i} {print \$1, \$target}' \
            \${cell_line_basename}.mageck.gene_summary.txt > \${cell_line_basename}.mageck.gene_summary.tmp
        
        mv \${cell_line_basename}.mageck.gene_summary.tmp \${cell_line_basename}.mageck.gene_summary.txt
    else
        echo "Skipping MAGeCK for \${cell_line_basename}: insufficient treatments or invalid input matrix."
    fi
    """
}