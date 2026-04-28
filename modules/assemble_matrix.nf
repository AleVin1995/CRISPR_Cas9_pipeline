process ASSEMBLE_MATRIX {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path norm_lfc_files

    def output_file = "sgrna_norm_lfc_assembled.tsv"

    output:
    path "${output_file}", emit: assembled_matrix

    script:
    """
    eval "\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)"

    Rscript ${projectDir}/../src/assemble_matrix.R \
        ${norm_lfc_files.join(',')} \
        ${output_file}
    """
}