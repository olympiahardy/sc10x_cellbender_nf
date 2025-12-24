include { CELLBENDER_REMOVE_BACKGROUND } from '../../modules/local/cellbender_remove_background'
include { SCANPY_QC_CELLRANGER       } from '../../modules/local/scanpy_qc_cellbender'

workflow SINGLE_SAMPLE_QC {

    take:
    ch_samples   // tuple(sample_id, cellranger_dir)

    main:
    // 1. run cellbender on filtered .h5
    CELLBENDER_REMOVE_BACKGROUND(ch_samples)

    // 2. QC using filtered + corrected
    SCANPY_QC_CELLRANGER(CELLBENDER_REMOVE_BACKGROUND.out.cb_out)

    emit:
    adata_raw = SCANPY_QC_CELLRANGER.out.adata
    qc_pdf    = SCANPY_QC_CELLRANGER.out.qc_pdf
}