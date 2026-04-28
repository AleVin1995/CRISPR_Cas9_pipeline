include { COMPUTE_NORM_LFC } from '../modules/compute_norm_lfc.nf'

workflow {
    batch_files = Channel
        .fromPath(params.input_batches, type: 'any')
        .flatMap { item ->
            item.isDirectory()
                ? item.listFiles().collect { file -> tuple(item.name, file) }
                : [ tuple(item.parent.name, item) ]
        }
    
    COMPUTE_NORM_LFC(batch_files)
}