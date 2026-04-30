include { COMPUTE_NORM_LFC } from '../modules/compute_norm_lfc.nf'
include { ASSEMBLE_MATRIX } from '../modules/assemble_matrix.nf'
include { AVERAGE_MATRIX } from '../modules/average_matrix.nf'

workflow {
    // Compute normalised counts and log fold changes for each batch of sgRNA counts
    batch_files = Channel
        .fromPath(params.input_batches, type: 'any')
        .flatMap { item ->
            item.isDirectory()
                ? item.listFiles().collect { file -> tuple(item.name, file) }
                : [ tuple(item.parent.name, item) ]
        }
    
    COMPUTE_NORM_LFC(batch_files)

    // Assemble the normalised log fold change files into a single matrix
    norm_lfc_files = COMPUTE_NORM_LFC.out.norm_lfc_files
    
    ASSEMBLE_MATRIX(norm_lfc_files.flatten().collect())

    // Average the sgRNA log fold changes to get gene-level log fold changes
    AVERAGE_MATRIX(ASSEMBLE_MATRIX.out.sgrna_norm_lfc_assembled)
    gene_norm_lfc_assembled = AVERAGE_MATRIX.out.gene_norm_lfc_assembled
}