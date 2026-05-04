include { BIAS_CORRECTION } from '../modules/bias_correction.nf'
include { ASSEMBLE_MATRIX as ASSEMBLE_LFC_MATRIX } from '../modules/assemble_matrix.nf'
include { AVERAGE_MATRIX } from '../modules/average_matrix.nf'
include { QUALITY_CONTROL } from '../modules/quality_control.nf'
include { GENE_CLASSIFICATION } from '../modules/gene_classification.nf'

workflow PREPROCESSING_WORKFLOW {
    main:
    // Compute corrected log fold changes for each batch of sgRNA counts
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
    
    ASSEMBLE_LFC_MATRIX(
        lfc_corr_qc_files, 
        params.lfc_sgrna_all, 
        params.join_col_lfc, 
        params.drop_col_lfc
    )

    // Average the sgRNA log fold changes to get gene-level log fold changes
    lfc_sgrna_qc_matrix = ASSEMBLE_LFC_MATRIX.out.matrix_all

    AVERAGE_MATRIX(lfc_sgrna_qc_matrix)
    lfc_gene_qc = AVERAGE_MATRIX.out.lfc_gene_qc

    // Classify genes based on their dependency scores across samples
    GENE_CLASSIFICATION(
        lfc_gene_qc,
        file(params.pos_ctrl_genes),
        file(params.neg_ctrl_genes)
    )

    emit:
    qc_results = QUALITY_CONTROL.out.lfc_corr_qc
    batch_files = batch_files.map { batch_name, file -> tuple(batch_name, file) }
}