process COMPUTE_RAW_LFC {
    tag "${input_dir.name}"
    publishDir "${params.raw_lfc_dir}/${input_dir.name}", mode: 'copy'

    input:
    path input_dir // directory containing batch of sgRNA counts

    output:
    path "*.tsv"

    script:
    """
    eval "\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)"
    
    for file in ${input_dir}/*; do
        Rscript ${projectDir}/../src/compute_raw_lfc.R \$(realpath \$file) \
            ${params.crispr_lib} \
            ${params.min_reads}
    done
    """
}