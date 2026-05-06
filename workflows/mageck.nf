include { ASSEMBLE_MATRIX as ASSEMBLE_MAGECK_MATRIX } from '../modules/assemble_matrix.nf'
include { RUN_MAGECK } from '../modules/run_mageck.nf'

workflow RUN_MAGECK_WORKFLOW {
    take:
    qc_results // Output channel from the QUALITY_CONTROL process 
    // in the PREPROCESSING_WORKFLOW, which contains the corrected
    // LFC files that passed QC
    batch_files // Output channel from the initial batch file 
    // collection step in the PREPROCESSING_WORKFLOW, which contains 
    // all the raw batch files before QC filtering

    main:
    // Select only file batches whose cell line passed the QC step
    passed_qc_names = qc_results
        .map { f -> f.baseName.replaceAll("_lfc_corr_qc", "") }
        .collect()
        .map { it.toSet() }

    batch_files_qc = batch_files
        .combine(passed_qc_names)
        .filter { batch_name, file, qc_set ->
            def cell_line = file.name.split("[._]")[0]
            qc_set.contains(cell_line)
        }
        .map { batch_name, file, qc_set -> tuple(batch_name, file) }

    RUN_MAGECK(batch_files_qc, file(params.design_matrix_mageck_script))

    // Assemble the MAGeCK gene summary files into a single matrix
    mageck_files = RUN_MAGECK.out.mageck.flatten().collect()

    ASSEMBLE_MAGECK_MATRIX(
        mageck_files, 
        params.mageck_gene_all, 
        params.join_col_mageck, 
        params.drop_col_mageck
    )
}