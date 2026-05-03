process GENE_CLASSIFICATION {
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