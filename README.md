# Infrastruture for Edwin's Websites

Deploying:
```bash
# I kept my secrets in a file and then just used the var-file to pass it to terraform.

Terraform init
Terraform plan
Terraform apply

# For debugging
Terraform state list

```

## Variables in var-file or environment variables
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
CLOUDFLARE_EMAIL
CLOUDFLARE_API_KEY
CLOUDFLARE_API_USER_SERVICE_KEY -- in the same place as API key