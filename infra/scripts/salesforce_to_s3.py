import sys
import boto3
from datetime import datetime, timezone
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "salesforce_object",
    "salesforce_connection_name",
    "s3_output_path",
    "watermark_ssm_param",
    "aws_region",
])

sc = SparkContext()
glueContext = GlueContext(sc)
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

ssm = boto3.client("ssm", region_name=args["aws_region"])

try:
    watermark = ssm.get_parameter(Name=args["watermark_ssm_param"])["Parameter"]["Value"]
except ssm.exceptions.ParameterNotFound:
    watermark = "1970-01-01T00:00:00.000+0000"

source = glueContext.create_dynamic_frame.from_options(
    connection_type="salesforce",
    connection_options={
        "connectionName": args["salesforce_connection_name"],
        "ENTITY_NAME": args["salesforce_object"],
        "API_VERSION": "59.0",
        "OPERATION": "SELECT",
        "filterPredicate": f"LastModifiedDate >= {watermark}",
    },
    transformation_ctx="salesforce_source",
)

if source.count() == 0:
    job.commit()
    sys.exit(0)

now = datetime.now(timezone.utc)
partition_path = (
    f"{args['s3_output_path']}/{args['salesforce_object']}"
    f"/year={now.year}/month={now.month:02d}/day={now.day:02d}"
    f"/hour={now.hour:02d}/minute={now.minute:02d}"
)

glueContext.write_dynamic_frame.from_options(
    frame=source,
    connection_type="s3",
    connection_options={"path": partition_path},
    format="parquet",
    transformation_ctx="s3_sink",
)

max_lmd = source.toDF().agg({"LastModifiedDate": "max"}).collect()[0][0]
if max_lmd:
    ssm.put_parameter(
        Name=args["watermark_ssm_param"],
        Value=str(max_lmd),
        Type="String",
        Overwrite=True,
    )

job.commit()