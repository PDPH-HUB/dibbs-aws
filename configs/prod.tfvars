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
    "subnet-0b5f36d63e75c9194",
    "subnet-0e008a543ea2bba3f"
]

private_subnets = [
    "subnet-01208b033707666bb",
    "subnet-033f13c263267da57"
  ]

vpc_id = "vpc-0170a65e2379f875e"
cert_name = "pdphdibbs.phila.gov"

# ------------------------------------------------------------------------------------------------------
# Application Configurations
# ------------------------------------------------------------------------------------------------------
# This defines the application version being deployed and the resources they're deployed with
# ------------------------------------------------------------------------------------------------------

phdi_version = "8.4.0"

task_size_overrides = [ 
    
    # fhir-converter
    {
        cpu = 2048
        memory = 4096
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
auth_client_id  = "910cc61a-9dcc-4cef-9fbe-2a9dcf87fbd9"
auth_issuer     = "2046864f-68ea-497d-af34-a6629a6cd700"
auth_url        = "https://pdphdibbs.phila.gov/ecr-viewer/api/auth"

# ------------------------------------------------------------------------------------------------------
# AWS Secrets Manager References
# ------------------------------------------------------------------------------------------------------
# These reference secrets managed in AWS
# ------------------------------------------------------------------------------------------------------

secret_manager__auth_secret_version = "AUTH_SECRET_VERSION"
secret_manager__auth_client_secret_version = "AUTH_CLIENT_SECRET_VERSION"
secret_manager__connection_string_version = "PROD_SQL_CONNECTION_STRING"