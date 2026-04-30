process AVERAGE_MATRIX {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path lfc_sgrna_all

    output:
    path params.lfc_gene_all, emit: lfc_gene_all

    script:
    template 'average_matrix.R'
}