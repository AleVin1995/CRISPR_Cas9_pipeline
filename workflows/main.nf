include { COMPUTE_RAW_LFC } from '../modules/compute_raw_lfc.nf'

workflow {
    batch_files = Channel
        .fromPath(params.input_batches, type: 'any')
        .flatMap { item ->
            item.isDirectory()
                ? item.listFiles().collect { file -> tuple(item.name, file) }
                : [ tuple(item.parent.name, item) ]
        }
    
    COMPUTE_RAW_LFC(batch_files)
}