process AVERAGE_MATRIX {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path sgrna_norm_lfc_assembled

    output:
    path params.gene_norm_lfc_assembled, emit: gene_norm_lfc_assembled

    script:
    template 'average_matrix.R'
}