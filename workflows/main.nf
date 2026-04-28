include { COMPUTE_RAW_LFC } from '../modules/compute_raw_lfc.nf'

workflow {
    batch_files = Channel
        .fromPath(params.input_batches, type: 'dir')
        .flatMap { dir -> dir.listFiles().collect { file -> tuple(dir.name, file) } }
    
    COMPUTE_RAW_LFC(batch_files)
}