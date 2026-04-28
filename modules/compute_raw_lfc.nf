process COMPUTE_RAW_LFC {
    tag "${batch_name}/${input_file.name}"
    publishDir "${params.raw_lfc_dir}/${batch_name}", mode: 'copy'

    input:
    tuple val(batch_name), path(input_file)

    output:
    path "*.tsv"

    script:
    """
    eval "\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)"
    
    Rscript ${projectDir}/../src/compute_raw_lfc.R \$(realpath ${input_file}) \
        ${params.crispr_lib} \
        ${params.min_reads}
    """
}