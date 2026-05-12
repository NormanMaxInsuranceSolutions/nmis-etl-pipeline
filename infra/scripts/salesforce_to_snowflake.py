import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "salesforce_object",
    "snowflake_database",
    "snowflake_schema",
    "salesforce_connection_name",
    "snowflake_connection_name",
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

salesforce_object = args["salesforce_object"]
snowflake_database = args["snowflake_database"]
snowflake_schema = args["snowflake_schema"]
salesforce_connection_name = args["salesforce_connection_name"]
snowflake_connection_name = args["snowflake_connection_name"]

source = glueContext.create_dynamic_frame.from_options(
    connection_type="salesforce",
    connection_options={
        "connectionName": salesforce_connection_name,
        "ENTITY_NAME": salesforce_object,
        "API_VERSION": "59.0",
        "OPERATION": "SELECT",
    },
    transformation_ctx="salesforce_source",
)

glueContext.write_dynamic_frame.from_options(
    frame=source,
    connection_type="snowflake",
    connection_options={
        "connectionName": snowflake_connection_name,
        "dbtable": salesforce_object.lower(),
        "database": snowflake_database,
        "schema": snowflake_schema,
    },
    transformation_ctx="snowflake_sink",
)

job.commit()