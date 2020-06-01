import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME','TEMP_STORAGE','OUTPUT_PATH','DB_NAME','TABLE_NAME','OUTPUT_FORMAT'])
glue_temp_storage = args['TEMP_STORAGE']
glue_relationalize_output_s3_path =  args['OUTPUT_PATH']
dfc_root_table_name = "root" #default value is "roottable"
db_name = args['DB_NAME']
table_name = args['TABLE_NAME']
output_fmt = args['OUTPUT_FORMAT']

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = db_name, table_name = "src", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = db_name, table_name = table_name, transformation_ctx = "datasource0")

dfc = Relationalize.apply(frame = datasource0, staging_path = glue_temp_storage, name = dfc_root_table_name, transformation_ctx = "dfc")
data = dfc.select(dfc_root_table_name)

output = glueContext.write_dynamic_frame.from_options(frame = data, connection_type = "s3", connection_options = {"path": glue_relationalize_output_s3_path}, format = output_fmt, transformation_ctx = "output")
job.commit()