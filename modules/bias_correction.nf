process BIAS_CORRECTION {
    tag "${batch_name}/${input_file.name}"

    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.lfc_corr_dir}/${batch_name}", mode: 'copy', pattern: "*_lfc_corr.tsv"
    publishDir "${params.count_norm_dir}/${batch_name}", mode: 'copy', pattern: "*_count_norm.tsv"

    input:
    tuple val(batch_name), path(input_file)

    output:
    path "*_lfc_corr.tsv", emit: lfc_corr, optional: true
    path "*_count_norm.tsv", emit: count_norm, optional: true

    script:
    template 'bias_correction.R'
}