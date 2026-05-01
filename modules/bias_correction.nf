process BIAS_CORRECTION {
    tag "${batch_name}/${input_file.name}"

    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.lfc_corr_dir}", mode: 'copy', pattern: "*_lfc_corr.tsv"

    input:
    tuple val(batch_name), path(input_file)

    output:
    path "*_lfc_corr.tsv", emit: lfc_corr, optional: true
    path "skipped_cell_line.log", emit: skipped_cell_line, optional: true

    script:
    template 'bias_correction.R'
}