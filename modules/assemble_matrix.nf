process ASSEMBLE_MATRIX {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path norm_lfc_files

    output:
    path params.sgrna_norm_lfc_assembled, emit: sgrna_norm_lfc_assembled

    script:
    template 'assemble_matrix.R'
}