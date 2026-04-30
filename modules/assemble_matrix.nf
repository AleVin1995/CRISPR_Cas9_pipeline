process ASSEMBLE_MATRIX {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path lfc_corr_files
    val matrix_name
    val join_cols
    val drop_cols

    output:
    path matrix_name, emit: matrix_all

    script:
    template 'assemble_matrix.R'
}