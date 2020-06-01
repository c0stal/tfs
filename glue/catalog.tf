# Define the glue data catalog first
resource "aws_glue_catalog_database" "catalog_database" {
  name        = "${local.product}_${local.service}_${local.environment}_db"
  description = "Glue Catalog database for ${local.product} ${local.service}  ${local.environment}"
}


resource "aws_glue_crawler" "datalake_crawler" {
  database_name = aws_glue_catalog_database.catalog_database.name
  name          = "${local.product}_${local.service}_${local.environment}_default_crawler"
  role          = aws_iam_role.aws_glue_role.name

  s3_target {
    path       = var.datastore_bucket
    exclusions = ["dst/**", "temp/**", "dst**", "temp**"]
  }
  classifiers   = ["json"]
  configuration = <<EOF
{
  "Version":1.0,
  "Grouping": {
    "TableGroupingPolicy": "CombineCompatibleSchemas"
  },
  "CrawlerOutput": {
      "Tables": { "AddOrUpdateBehavior": "MergeNewColumns" },
       "Partitions": { "AddOrUpdateBehavior": "InheritFromTable" }
   }
}
EOF
}

resource "aws_cloudwatch_log_group" "glue_log_group" {
  name              = "${local.product}_${local.service}_${local.environment}_log_group"
  retention_in_days = 1
}

resource "aws_glue_job" "glue_job" {
  name     = "${local.product}_${local.service}_${local.environment}_job"
  role_arn = aws_iam_role.aws_glue_role.arn

  command {
    script_location = var.script_location
  }

  default_arguments = {
    # ... potentially other arguments ...
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.glue_log_group.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "noop"
    "--TEMP_STORAGE"                     = "${var.output_bucket}/temp"
    "--OUTPUT_PATH"                      = "${var.output_bucket}/dst"
    "--DB_NAME"                          = aws_glue_catalog_database.catalog_database.name
    "--TABLE_NAME"                       = "<<table created by the crawler>>"
    "--OUTPUT_FORMAT" = "csv"
  }
}


