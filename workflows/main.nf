include { RUN_BAGEL_WORKFLOW } from './bagel.nf'
include { RUN_MAGECK_WORKFLOW } from './mageck.nf'
include { PREPROCESSING_WORKFLOW } from './preprocessing.nf'

workflow {
    // Run the preprocessing workflow to compute corrected log fold changes, 
    // perform QC, and classify genes
    PREPROCESSING_WORKFLOW()

    // If option available, run MAGeCK on each batch of sgRNA counts independently
    if (params.mageck_run) {
        RUN_MAGECK_WORKFLOW(
            PREPROCESSING_WORKFLOW.out.qc_results,
            PREPROCESSING_WORKFLOW.out.batch_files
        )
    }

    // Run BAGEL on the quality-controlled log fold change files
    if (params.bagel_run) {
        RUN_BAGEL_WORKFLOW(
            PREPROCESSING_WORKFLOW.out.qc_results
        )
    }
}