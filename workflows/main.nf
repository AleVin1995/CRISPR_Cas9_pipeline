include { BIAS_CORRECTION } from '../modules/bias_correction.nf'
include { ASSEMBLE_MATRIX as ASSEMBLE_MATRIX_LFC } from '../modules/assemble_matrix.nf'
include { ASSEMBLE_MATRIX as ASSEMBLE_MATRIX_BF } from '../modules/assemble_matrix.nf'
include { AVERAGE_MATRIX } from '../modules/average_matrix.nf'
include { QUALITY_CONTROL } from '../modules/quality_control.nf'
include { RUN_BAGEL } from '../modules/run_bagel.nf'

workflow {
    // Compute normalised counts and corrected log fold changes 
    // for each batch of sgRNA counts
    batch_files = Channel
        .fromPath(params.input_batches, type: 'any')
        .flatMap { item ->
            item.isDirectory()
                ? item.listFiles().collect { file -> tuple(item.name, file) }
                : [ tuple(item.parent.name, item) ]
        }
    
    BIAS_CORRECTION(batch_files)

    // Collect skipped cell line names into a single log file
    BIAS_CORRECTION.out.skipped_cell_line
        .collectFile(name: 'skipped_cell_line.log', storeDir: params.log_dir,
        seed: "Cell lines skipped due to insufficient treatment samples:\n")
    
    // Perform quality control on each corrected LFC file independently
    lfc_corr_files = BIAS_CORRECTION.out.lfc_corr.flatten()
    
    QUALITY_CONTROL(
        lfc_corr_files,
        file(params.pos_ctrl_genes),
        file(params.neg_ctrl_genes)
    )

    // Move low QC log files to the log directory
    QUALITY_CONTROL.out.low_qc_samples
        .collectFile(name: 'low_qc_samples.log', storeDir: params.log_dir,
        seed: "Samples with low QC (AUROC below threshold):\n")

    // Assemble the corrected log fold change files into a single matrix
    lfc_corr_qc_files = QUALITY_CONTROL.out.lfc_corr_qc.flatten().collect()
    
    ASSEMBLE_MATRIX_LFC(
        lfc_corr_qc_files, 
        params.lfc_sgrna_all, 
        params.join_col_lfc, 
        params.drop_col_lfc
    )

    // Run BAGEL on the quality-controlled log fold change files
    lfc_corr_qc_files = QUALITY_CONTROL.out.lfc_corr_qc.flatten()

    RUN_BAGEL(
        lfc_corr_qc_files,
        file(params.pos_ctrl_genes),
        file(params.neg_ctrl_genes)
    )

    // Assemble the BAGEL Bayes factor files into a single matrix
    bf_files = RUN_BAGEL.out.bagel.flatten().collect()

    ASSEMBLE_MATRIX_BF(
        bf_files, 
        params.bf_gene_all, 
        params.join_col_bf, 
        params.drop_col_bf
    )

    // Average the sgRNA log fold changes to get gene-level log fold changes
    lfc_sgrna_qc_matrix = ASSEMBLE_MATRIX_LFC.out.matrix_all

    AVERAGE_MATRIX(lfc_sgrna_qc_matrix)
    lfc_gene_qc = AVERAGE_MATRIX.out.lfc_gene_qc
}