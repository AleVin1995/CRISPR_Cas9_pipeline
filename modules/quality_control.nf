process QUALITY_CONTROL {
    publishDir "${params.lfc_corr_qc_dir}", mode: 'copy', pattern: "*_lfc_corr_qc.tsv"

    input:
    path lfc_corr
    path pos_ctrl_genes
    path neg_ctrl_genes

    output:
    path "*_lfc_corr_qc.tsv", emit: lfc_corr_qc, optional: true
    path "low_qc_samples.log", emit: low_qc_samples, optional: true

    script:
    template 'quality_control.R'
}