process COMPUTE_NORM_LFC {
    tag "${batch_name}/${input_file.name}"

    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.norm_lfc_dir}/${batch_name}", mode: 'copy', pattern: "*_norm_lfc.tsv"
    publishDir "${params.norm_counts_dir}/${batch_name}", mode: 'copy', pattern: "*_norm_counts.tsv"

    input:
    tuple val(batch_name), path(input_file)

    output:
    path "*_norm_lfc.tsv", emit: norm_lfc_files, optional: true
    path "*_norm_counts.tsv", emit: norm_counts_files, optional: true

    script:
    template 'compute_norm_lfc.R'
}