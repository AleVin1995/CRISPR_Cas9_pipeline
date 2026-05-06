include { ASSEMBLE_MATRIX as ASSEMBLE_BF_MATRIX } from '../modules/assemble_matrix.nf'
include { RUN_BAGEL } from '../modules/run_bagel.nf'

workflow RUN_BAGEL_WORKFLOW {
    take:
    qc_results // Output channel from the QUALITY_CONTROL process 
    // in the PREPROCESSING_WORKFLOW, which contains the corrected
    // LFC files that passed QC

    main:
    // Run BAGEL on the quality-controlled log fold change files
    lfc_corr_qc_files = qc_results.flatten()

    RUN_BAGEL(
        lfc_corr_qc_files,
        file(params.bagel_script),
        file(params.pos_ctrl_genes),
        file(params.neg_ctrl_genes)
    )

    // Assemble the BAGEL Bayes factor files into a single matrix
    bf_files = RUN_BAGEL.out.bagel.flatten().collect()

    ASSEMBLE_BF_MATRIX(
        bf_files, 
        params.bf_gene_all, 
        params.join_col_bf, 
        params.drop_col_bf
    )
}