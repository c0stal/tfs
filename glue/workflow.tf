resource "aws_glue_workflow" "glue_workflow" {
  name = "${local.product}_${local.service}_${local.environment}_workflow"
}

resource "aws_glue_trigger" "trigger_start" {
  name          = "${local.product}_${local.service}_${local.environment}_tgr_start"
  type          = "ON_DEMAND"
  workflow_name = aws_glue_workflow.glue_workflow.name

  actions {
    crawler_name = aws_glue_crawler.datalake_crawler.name
  }
}

resource "aws_glue_trigger" "job_trigger" {
  name          = "${local.product}_${local.service}_${local.environment}_tgr_job"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.glue_workflow.name
  actions {
    job_name = aws_glue_job.glue_job.name
  }

  predicate {
    conditions {
      crawler_name = aws_glue_crawler.datalake_crawler.name
      crawl_state  = "SUCCEEDED"
    }
  }
}