include { BIAS_CORRECTION } from '../modules/bias_correction.nf'
include { ASSEMBLE_MATRIX } from '../modules/assemble_matrix.nf'
include { AVERAGE_MATRIX } from '../modules/average_matrix.nf'
include { QUALITY_CONTROL } from '../modules/quality_control.nf'

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

    // Assemble the corrected log fold change files into a single matrix
    lfc_corr_files = BIAS_CORRECTION.out.lfc_corr.flatten().collect()
    
    ASSEMBLE_MATRIX(lfc_corr_files)

    // Perform quality control on the sgRNA log fold change matrix
    QUALITY_CONTROL(
        ASSEMBLE_MATRIX.out.lfc_sgrna_all,
        file(params.pos_ctrl_genes),
        file(params.neg_ctrl_genes)
    )

    // Average the sgRNA log fold changes to get gene-level log fold changes
    AVERAGE_MATRIX(QUALITY_CONTROL.out.lfc_sgrna_qc)
    lfc_gene_qc = AVERAGE_MATRIX.out.lfc_gene_qc
}