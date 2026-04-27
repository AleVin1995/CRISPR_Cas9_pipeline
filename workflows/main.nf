include { ASSEMBLE_MATRIX } from '../modules/assemble.nf'

workflow {
    batch_folder = Channel.fromPath(params.input_batches, type: 'dir')
    ASSEMBLE_MATRIX(batch_folder)
}