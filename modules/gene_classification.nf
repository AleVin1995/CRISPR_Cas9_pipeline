process GENE_CLASSIFICATION {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path lfc_gene_qc
    path pos_ctrl_genes
    path neg_ctrl_genes

    output:
    path params.gene_class, emit: gene_class

    script:
    template 'gene_classification.R'
}