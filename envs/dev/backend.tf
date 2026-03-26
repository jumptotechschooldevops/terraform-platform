bucket         = "CHANGE-ME-terraform-state-bucket"
key            = "terraform-platform/dev/terraform.tfstate"
region         = "us-east-2"
encrypt        = true
dynamodb_table = "terraform-state-locks"
use_lockfile   = true
