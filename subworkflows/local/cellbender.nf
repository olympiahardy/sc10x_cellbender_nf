include { CELLBENDER_REMOVE_BACKGROUND } from '../../modules/local/cellbender_remove_background'

workflow CELLBENDER {

    take:
    ch_samples   // This is a tuple defined in main.nf that contains the sample_id and the CellRanger outs directory path
    main:
    // Run the process in Cellbender_remove_background.nf which we call above
    CELLBENDER_REMOVE_BACKGROUND(ch_samples)

    emit: // Extract the outputs of Cellbender_remove_background.nf which will be the two h5 files one corrected one raw
    cb_out = CELLBENDER_REMOVE_BACKGROUND.out.cb_out
}