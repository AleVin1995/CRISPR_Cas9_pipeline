process ASSEMBLE_MATRIX {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path norm_lfc_files

    def output_file = "sgrna_norm_lfc_assembled.tsv"

    output:
    path "${output_file}", emit: assembled_matrix

    script:
    template 'assemble_matrix.R'
}