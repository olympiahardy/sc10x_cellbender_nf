nextflow.enable.dsl = 2

process SCANPY_QC_CELLRANGER {

    tag "$sample_id"
    label 'scanpy_qc'
    conda "envs/scanpy_env.yml"

    input:
    tuple val(sample_id),
          path(filtered_h5),
          path(cellbender_h5)

    output:
    path("${sample_id}.h5ad")                , emit: adata
    path("${sample_id}_qc_violin_plots.pdf"), emit: qc_pdf

    script:
    """
    echo 'Starting QC for sample: ${sample_id}'
    echo "Filtered h5: ${filtered_h5}"
    echo "CellBender h5: ${cellbender_h5}"

    python ${projectDir}/scripts/qc_cellbender.py \
        --filtered_h5 ${filtered_h5} \
        --cellbender_h5 ${cellbender_h5} \
        --sample_id ${sample_id} \
        --outdir .

    echo 'Finished QC for ${sample_id}'
    """
}