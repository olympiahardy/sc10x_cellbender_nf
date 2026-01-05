nextflow.enable.dsl = 2
// This main.nf is the main entry point for the Nextflow pipeline that will run every subworkflow like calling a function
include { CELLBENDER } from './subworkflows/local/cellbender'
// input_glob is a parameter that the user will use in the nextflow launch command that should point to the CellRanger 'outs' directories
params.input_glob = params.input_glob ?: null
params.outdir     = params.outdir     ?: null
// This is the actual execution of the pipeline
workflow {
    // First we validate the input/output paths provided by the user
    if ( !params.input_glob ) {
        error "You must provide --input_glob, this should be your directory path to your CellRanger 'outs' directories, for example '/path/to/*/outs'"
    }

    if ( !params.outdir ) {
    error "You must provide --outdir, where do you want your results to be saved?"
    }   

    log.info "Loading CellRanger samples from: ${params.input_glob}"
    log.info "Outputs will be saved to: ${params.outdir}"
    log.info "Running CellBender on all samples..."
    // Here we create a Channel that contains tuples of sample_id and the CellRanger outs directory path for each sample found
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
    // Now we call the CELLBENDER subworkflow defined above passing in the ch_samples Channel we just created
    CELLBENDER(ch_samples)
}
// Just printing a finished message when the pipeline is complete
workflow.onComplete {
    log.info "Pipeline complete! Outputs can be found in: ${params.outdir}"
}