process COMPUTE_RAW_LFC {
    tag "${batch_name}/${input_file.name}"
    publishDir "${params.raw_lfc_dir}/${batch_name}", mode: 'copy', pattern: "*_raw_lfc.tsv"
    publishDir "${params.norm_counts_dir}/${batch_name}", mode: 'copy', pattern: "*_norm_counts.tsv"

    input:
    tuple val(batch_name), path(input_file)

    output:
    path "*_raw_lfc.tsv", emit: raw_lfc_files
    path "*_norm_counts.tsv", emit: norm_counts_files

    script:
    """
    eval "\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)"

    Rscript ${projectDir}/../src/compute_raw_lfc.R \$(realpath ${input_file}) \
        ${params.crispr_lib} \
        ${params.min_reads} \
        ${params.n_controls} \
        ${params.scaling_method}
    """
}