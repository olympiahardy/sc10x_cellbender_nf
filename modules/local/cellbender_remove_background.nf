nextflow.enable.dsl = 2
// This file denotes the actual running of CellBender on each sample in a CellRanger results directory
process CELLBENDER_REMOVE_BACKGROUND {

    tag "$sample_id"
    label 'cellbender'

    // This will be the name of your environment file, for this pipeline its called scanpy_env.yml
    conda "envs/scanpy_env.yml"

    input:
    tuple val(sample_id), path(cellranger_dir)

    output:
    // This makes it so that the output is two h5 files of the original uncorrected matrix and the Cellbender corrected matrix so we can compare downstream
    tuple val(sample_id),
          path("*_raw_input.h5"),
          path("*_cellbender_output.h5"),
          emit: cb_out

    script:
    """
    set -euo pipefail

    echo "Starting CellBender for sample: ${sample_id}"
    echo "CellRanger outs dir: ${cellranger_dir}"

    # Try to find the raw feature matrix H5 in the outs directory
    RAW_H5=""
    if [ -f "${cellranger_dir}/raw_feature_bc_matrix.h5" ]; then
        RAW_H5="${cellranger_dir}/raw_feature_bc_matrix.h5"
    else
        # Error if raw file not found
        echo "ERROR: Pipeline stopped: raw_feature_bc_matrix.h5 is missing for sample ${sample_id}" >&2
        ls -lh ${cellranger_dir} || true
        exit 1
    fi

    echo "Using raw h5 file: \$RAW_H5"

    RAW_OUT="${sample_id}_raw_input.h5"
    CB_OUT="${sample_id}_cellbender_output.h5"

    # Create a local copy with a sample-specific name
    cp "\$RAW_H5" "\$RAW_OUT"

    echo "Running CellBender for sample: ${sample_id}"

    # Running CellBender

    # First we check whether or not the system the pipeline is running on has a GPU available
    CUDA_FLAG=""
    if command -v nvidia-smi &>/dev/null; then
    echo "GPU detected, enabling CUDA"
    CUDA_FLAG="--cuda"
    else
    echo "No GPU detected, running on CPU"
    fi

    # Actual CellBender call

    cellbender remove-background \
    --input "\$RAW_OUT" \
    --output "\$CB_OUT" \
    \$CUDA_FLAG

    echo "Finished CellBender for sample: ${sample_id}"
    """
}