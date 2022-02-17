#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/controldna
========================================================================================
    Github : https://github.com/nf-core/controldna
    Website: https://nf-co.re/controldna
    Slack  : https://nfcore.slack.com/channels/controldna
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { CONTROLDNA } from './workflows/controldna'

//
// WORKFLOW: Run main nf-core/controldna analysis pipeline
//
workflow NFCORE_CONTROLDNA {
    CONTROLDNA ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_CONTROLDNA ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
