## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.86.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.56.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | CDCgov/dibbs-ecr-viewer/aws | 0.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_secretsmanager_secret.secret_auth_client_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.secret_nextauth_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.secret_sql_database_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.secret_sql_database_pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.secret_sql_database_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.secret-version-authclient-secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.secret-version-host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.secret-version-nextauth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.secret-version-pass](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.secret-version-user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_client_id"></a> [auth\_client\_id](#input\_auth\_client\_id) | The application/client id used to idenitfy the client | `string` | `""` | no |
| <a name="input_auth_issuer"></a> [auth\_issuer](#input\_auth\_issuer) | Additional information used during authentication process. For Azure AD, this will be the 'Tenant Id'. For Keycloak, this will be the url issuer including the realm - e.g. https://my-keycloak-domain.com/realms/My_Realm | `string` | `""` | no |
| <a name="input_auth_provider"></a> [auth\_provider](#input\_auth\_provider) | The authentication provider used. Either keycloak or ad. | `string` | `"ad"` | no |
| <a name="input_auth_url"></a> [auth\_url](#input\_auth\_url) | Optional. The full URL of the auth api. By default https://your-site.com/ecr-viewer/api/auth. | `string` | `""` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones to use | `list(string)` | <pre>[<br/>  "us-east-1a",<br/>  "us-east-1b",<br/>  "us-east-1c"<br/>]</pre> | no |
| <a name="input_create_internet_gateway"></a> [create\_internet\_gateway](#input\_create\_internet\_gateway) | Flag to determine if an internet gateway should be created | `bool` | `false` | no |
| <a name="input_db_cipher"></a> [db\_cipher](#input\_db\_cipher) | Defines cipher string for NextJS communication with DB | `string` | `""` | no |
| <a name="input_ecr_viewer_database_schema"></a> [ecr\_viewer\_database\_schema](#input\_ecr\_viewer\_database\_schema) | The database schema used for the eCR data tables | `string` | `"core"` | no |
| <a name="input_ecr_viewer_database_type"></a> [ecr\_viewer\_database\_type](#input\_ecr\_viewer\_database\_type) | The SQL variant used for the eCR data tables | `string` | `"postgres"` | no |
| <a name="input_ecs_alb_sg"></a> [ecs\_alb\_sg](#input\_ecs\_alb\_sg) | The security group for the Application Load Balancer | `string` | `"ecs-albsg"` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable NAT Gateway | `bool` | `false` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the infrastructure | `string` | `"alis"` | no |
| <a name="input_phdi_version"></a> [phdi\_version](#input\_phdi\_version) | PHDI container image version | `string` | `"v1.7.6"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | The private subnets | `list(string)` | <pre>[<br/>  "176.31.1.0/24",<br/>  "176.31.3.0/24"<br/>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | The project name | `string` | `"dibbs"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | The public subnets | `list(string)` | <pre>[<br/>  "176.31.2.0/24",<br/>  "176.31.4.0/24"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_secret_manager__auth_client_secret_version"></a> [secret\_manager\_\_auth\_client\_secret\_version](#input\_secret\_manager\_\_auth\_client\_secret\_version) | The secret containing the auth client secret. This is the secret that comes from the authentication provider. | `string` | `""` | no |
| <a name="input_secret_manager__auth_secret_version"></a> [secret\_manager\_\_auth\_secret\_version](#input\_secret\_manager\_\_auth\_secret\_version) | The secret containing the auth secret. This is used by eCR viewer to encrypt authentication. This can be generated by running `openssl rand -base64 32`. | `string` | `""` | no |
| <a name="input_secret_manager__sql_database_host"></a> [secret\_manager\_\_sql\_database\_host](#input\_secret\_manager\_\_sql\_database\_host) | IP for the SQL Database service account used by ECR-Viewer | `string` | `""` | no |
| <a name="input_secret_manager__sql_database_password"></a> [secret\_manager\_\_sql\_database\_password](#input\_secret\_manager\_\_sql\_database\_password) | Password for the SQL Database service account used by ECR-Viewer | `string` | `""` | no |
| <a name="input_secret_manager__sql_database_user"></a> [secret\_manager\_\_sql\_database\_user](#input\_secret\_manager\_\_sql\_database\_user) | Username for the SQL Database service account used by ECR-Viewer | `string` | `""` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Single NAT Gateway | `bool` | `false` | no |
| <a name="input_task_size_overrides"></a> [task\_size\_overrides](#input\_task\_size\_overrides) | Variable to overide task sizes | <pre>list(<br/><br/>    object({<br/>      cpu             = number<br/>      memory          = number<br/>      max_capacity    = number<br/>      min_capacity    = number<br/>      target_cpu      = number<br/>      target_memory   = number<br/>    })<br/><br/>  )</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID for the VPC | `string` | `""` | no |

## Outputs

No outputs.
