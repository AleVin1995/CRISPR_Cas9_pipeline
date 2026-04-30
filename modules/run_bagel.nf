process RUN_BAGEL {
    tag "${input_file.name}"

    beforeScript "eval \"\$(pixi shell-hook --manifest-path ${projectDir}/../pixi.toml)\""

    publishDir "${params.bagel_dir}", mode: 'copy', pattern: "*.bf"

    input:
    path input_file
    path pos_ctrl_genes
    path neg_ctrl_genes

    output:
    path "*.bf", emit: bagel, optional: true

    script:
    """
    python3 ${projectDir}/../bagel/BAGEL.py bf \
        -i ${input_file} \
        -e ${pos_ctrl_genes} \
        -n ${neg_ctrl_genes} \
        -sg ${params.bagel_sgrna_col} \
        -g ${params.bagel_gene_col} \
        -o ${input_file.baseName}.bf \
        -c ${params.bagel_val_col} \
        --no-of-cross-validations ${params.bagel_n_cross_validations} \
        --seed 1234 \
        --bf-column-name ${input_file.baseName.split('[_.]')[0]}_bf
    """
}