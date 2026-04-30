process QUALITY_CONTROL {
    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.outdir}", mode: 'copy', pattern: "*.tsv"

    input:
    path lfc_sgrna_all
    path pos_ctrl_genes
    path neg_ctrl_genes

    output:
    path params.lfc_sgrna_qc, emit: lfc_sgrna_qc
    path "low_qc_samples.log", emit: low_qc_samples, optional: true

    script:
    template 'quality_control.R'
}