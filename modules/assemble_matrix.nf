process ASSEMBLE_MATRIX {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path norm_lfc_files

    output:
    path "norm_lfc_assembled.tsv", emit: assembled_matrix

    script:
    """
    eval "\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)"

    Rscript ${projectDir}/../src/assemble_matrix.R \
        ${norm_lfc_files.join(',')} \
        norm_lfc_assembled.tsv
    """
}