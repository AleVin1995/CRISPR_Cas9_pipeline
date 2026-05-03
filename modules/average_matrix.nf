process AVERAGE_MATRIX {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path lfc_sgrna_qc

    output:
    path params.lfc_gene_qc, emit: lfc_gene_qc

    script:
    template 'average_matrix.R'
}