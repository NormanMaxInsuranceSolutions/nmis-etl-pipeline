import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "salesforce_object",
    "snowflake_connection_name",
    "snowflake_database",
    "snowflake_schema",
    "s3_input_path",
])

sc = SparkContext()
glueContext = GlueContext(sc)
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

table_name  = args["salesforce_object"].lower()
stage_table = f"{table_name}_stage"
input_path  = f"{args['s3_input_path']}/{args['salesforce_object']}"

# Job bookmarks ensure only new S3 files written since the last run are read
source = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={
        "path": input_path,
        "recurse": True,
    },
    format="parquet",
    transformation_ctx="s3_source",
)

if source.count() == 0:
    job.commit()
    sys.exit(0)

glueContext.write_dynamic_frame.from_options(
    frame=source,
    connection_type="snowflake",
    connection_options={
        "connectionName": args["snowflake_connection_name"],
        "dbtable": stage_table,
        "database": args["snowflake_database"],
        "schema": args["snowflake_schema"],
        "preactions": f"TRUNCATE TABLE {stage_table}",
        "postactions": f"""
            MERGE INTO {table_name} t
            USING {stage_table} s ON t.id = s.id
            WHEN MATCHED AND s.is_deleted = TRUE THEN DELETE
            WHEN MATCHED THEN UPDATE SET *
            WHEN NOT MATCHED AND s.is_deleted = FALSE THEN INSERT *;
            TRUNCATE TABLE {stage_table};
        """,
    },
    transformation_ctx="snowflake_sink",
)

job.commit()