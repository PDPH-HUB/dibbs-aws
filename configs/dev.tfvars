# ------------------------------------------------------------------------------------------------------
# Project Naming Configurations
# ------------------------------------------------------------------------------------------------------
# These configure project naming conventions
# ------------------------------------------------------------------------------------------------------

owner = "pdph"
project = "dibbs-ce"
region = "us-east-1"

# ------------------------------------------------------------------------------------------------------
# Application Configurations
# ------------------------------------------------------------------------------------------------------
# This configures which version of PHDI is being deployed
# ------------------------------------------------------------------------------------------------------

ecr_viewer_database_type = "sqlserver"
ecr_viewer_database_schema = "AWS_SQLSERVER_NON_INTEGRATED"

# ------------------------------------------------------------------------------------------------------
# Network Configurations
# ------------------------------------------------------------------------------------------------------
# These manage network configurations for AWS
# ------------------------------------------------------------------------------------------------------

# Networking Variables:
public_subnets = [
    "subnet-09168f709ae97e72c",
    "subnet-09665482bd7366bf5"
]

private_subnets = [
    "subnet-0aefc8044e1e8247a",
    "subnet-01cbf19a991eecdb4"
  ]

vpc_id = "vpc-024d5f60537ead672"
waf_web_acl_arn = "arn:aws:wafv2:us-east-1:047719641506:regional/webacl/dibbs-ce-pdph-dev-waf/7b44bf52-9d27-4c8a-a967-93e66190c6b3"
cert_name = "dev-pdphdibbs.phila.gov"

# ------------------------------------------------------------------------------------------------------
# Application Configurations
# ------------------------------------------------------------------------------------------------------
# This defines the application version being deployed and the resources they're deployed with
# ------------------------------------------------------------------------------------------------------

phdi_version = "9.1.1"

task_size_overrides = [

    # [0] ecr-viewer
    {
        cpu = 512
        memory = 1024
        max_capacity = 5
        min_capacity = 1
        target_cpu = 60
        target_memory = 70
    },

    # [1] fhir-converter
    {
        cpu = 2048
        memory = 4096
        max_capacity = 5
        min_capacity = 1
        target_cpu = 60
        target_memory = 70
    },

    # [2] ingestion
    {
        cpu = 512
        memory = 1024
        max_capacity = 5
        min_capacity = 1
        target_cpu = 60
        target_memory = 70
    },

    # [3] message-parser
    {
        cpu = 512
        memory = 1024
        max_capacity = 5
        min_capacity = 1
        target_cpu = 60
        target_memory = 70
    },

    # [4] orchestration
    {
        cpu = 512
        memory = 1024
        max_capacity = 5
        min_capacity = 1
        target_cpu = 60
        target_memory = 70
    },

    # [5] trigger-code-reference
    {
        cpu = 512
        memory = 1024
        max_capacity = 5
        min_capacity = 1
        target_cpu = 60
        target_memory = 70
    }
]

# S3 Logging Bucket
enable_alb_logs = true

# ------------------------------------------------------------------------------------------------------
# Database Configurations
# ------------------------------------------------------------------------------------------------------
# These define the database configurations for the ECR viewer
# This does not include secrets for connecting to the database itself
# ------------------------------------------------------------------------------------------------------

db_cipher = "DEFAULT:@SECLEVEL=0"

# ------------------------------------------------------------------------------------------------------
# Authentication Details
# ------------------------------------------------------------------------------------------------------
# These define the connection with our auth provided
# ------------------------------------------------------------------------------------------------------

auth_provider   = "ad"
auth_client_id  = "b0ec2632-6c37-4ef8-a11f-720a4087a021"
auth_issuer     = "2046864f-68ea-497d-af34-a6629a6cd700"
auth_url        = "https://dev-pdphdibbs.phila.gov/ecr-viewer/api/auth"