include { CELLBENDER_REMOVE_BACKGROUND } from '../../modules/local/cellbender_remove_background'

workflow CELLBENDER {

    take:
    ch_samples   // tuple(sample_id, cellranger_dir)

    main:
    // 1. run cellbender on filtered .h5
    CELLBENDER_REMOVE_BACKGROUND(ch_samples)

    emit:
    cb_out = CELLBENDER_REMOVE_BACKGROUND.out.cb_out
}