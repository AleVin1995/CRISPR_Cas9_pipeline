include { COMPUTE_RAW_LFC } from '../modules/compute_raw_lfc.nf'

workflow {
    batch_folder = Channel.fromPath(params.input_batches, type: 'dir')
    COMPUTE_RAW_LFC(batch_folder)
}