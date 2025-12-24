nextflow.enable.dsl = 2

process CELLBENDER_REMOVE_BACKGROUND {

    tag "$sample_id"
    label 'cellbender'

    // use same env as Scanpy if you’ve installed cellbender there
    conda "envs/scanpy_env.yml"

    input:
    tuple val(sample_id), path(cellranger_dir)

    output:
    // pass forward both the raw h5 and the cellbender output h5
    tuple val(sample_id),
          path("h5_files/*_raw_input.h5"),
          path("h5_files/*_cellbender_output.h5"),
          emit: cb_out

    script:
    """
    set -euo pipefail

    echo "Starting CellBender for sample: ${sample_id}"
    echo "CellRanger outs dir: ${cellranger_dir}"

    mkdir -p h5_files

    # Try to find the raw feature matrix HDF5 in the outs directory
    RAW_H5=""
    if [ -f "${cellranger_dir}/raw_feature_bc_matrix.h5" ]; then
        RAW_H5="${cellranger_dir}/raw_feature_bc_matrix.h5"
    else
        # Fallback: first .h5 in outs/ that looks plausible
        RAW_H5=\$(ls ${cellranger_dir}/*.h5 | head -n 1 || true)
    fi

    if [ -z "\$RAW_H5" ] || [ ! -f "\$RAW_H5" ]; then
        echo "ERROR: Could not find a raw 10x .h5 file in: ${cellranger_dir}" >&2
        ls -lh ${cellranger_dir} || true
        exit 1
    fi

    echo "Using raw h5 file: \$RAW_H5"

    RAW_OUT="h5_files/${sample_id}_raw_input.h5"
    CB_OUT="h5_files/${sample_id}_cellbender_output.h5"

    # Create a local copy with a stable, sample-specific name
    cp "\$RAW_H5" "\$RAW_OUT"

    echo "Running CellBender for sample: ${sample_id}"

    # Run CellBender
    cellbender remove-background \
        --input "\$RAW_OUT" \
        --output "\$CB_OUT" \
        --cuda

    echo "Finished CellBender for sample: ${sample_id}"
    """
}