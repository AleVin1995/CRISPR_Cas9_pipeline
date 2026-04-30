process ASSEMBLE_MATRIX {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path lfc_corr_files

    output:
    path params.lfc_sgrna_all, emit: lfc_sgrna_all

    script:
    template 'assemble_matrix.R'
}