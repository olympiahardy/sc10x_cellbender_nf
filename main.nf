nextflow.enable.dsl = 2

include { SINGLE_SAMPLE_QC } from './subworkflows/local/single_sample_qc'

params.input_glob = params.input_glob ?: null
params.outdir     = params.outdir     ?: 'results'

workflow {

    if ( !params.input_glob ) {
        error "You must provide --input_glob, this should be your directory path to your CellRanger 'outs' directories, for example '/path/to/*/outs'"
    }

    log.info "Loading CellRanger samples from: ${params.input_glob}"
    log.info "Running CellBender + QC for all samples..."

    Channel
    .fromPath(params.input_glob, type: 'dir', followLinks: true)
    .view { dir -> log.info "Matched outs dir: ${dir}" }
    .ifEmpty { error "No input matched --input_glob: ${params.input_glob}" }
    .map { dir ->
        def sample_id = dir.parent.name
        tuple(sample_id, dir)
    }
    .set { ch_samples }

    ch_samples.view { "SAMPLE: ${it[0]}  DIR: ${it[1]}" }
    SINGLE_SAMPLE_QC(ch_samples)
}

workflow.onComplete {
    log.info "Pipeline complete! Outputs can be found in: ${params.outdir}"
}