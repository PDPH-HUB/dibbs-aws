owner   = "pdph"
project = "dibbs-ce"
region  = "us-east-1"

oidc_github_repo = "PDPH-HUB@89149833/dibbs-aws@1310128333"

dev_vpc_id  = "vpc-024d5f60537ead672"
prod_vpc_id = "vpc-0170a65e2379f875e"

dev_route53_hosted_zone_arn  = "arn:aws:route53:::hostedzone/Z07691153LDS8OGB3F2JN"
prod_route53_hosted_zone_arn = "arn:aws:route53:::hostedzone/Z03892602LM02CI72C8P0"

dev_waf_web_acl_arn  = "arn:aws:wafv2:us-east-1:047719641506:regional/webacl/dibbs-ce-pdph-dev-waf/7b44bf52-9d27-4c8a-a967-93e66190c6b3"
prod_waf_web_acl_arn = "arn:aws:wafv2:us-east-1:047719641506:regional/webacl/dibbs-ce-pdph-prod-waf/72a0b30e-be0a-4f84-8d2f-0715a9e9065d"

tfstate_bucket_arn         = "arn:aws:s3:::dibbs-ce-tfstate-pdph-s8bnxvvy"
tfstate_bucket_name        = "dibbs-ce-tfstate-pdph-s8bnxvvy"
tfstate_dynamodb_table_arn = "arn:aws:dynamodb:us-east-1:047719641506:table/dibbs-ce-tfstate-lock-pdph-s8bnxvvy"
