aws_region  = "us-east-2"
project_name = "terraform-platform"
environment  = "prod"
owner        = "devops"

vpc_cidr             = "10.30.0.0/16"
public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24"]
private_subnet_cidrs = ["10.30.11.0/24", "10.30.12.0/24"]

instance_type    = "t3.medium"
desired_capacity = 2
min_size         = 2
max_size         = 4

key_name = null

allowed_http_cidrs = ["0.0.0.0/0"]

db_name                = "appdb"
db_username            = "appadmin"
db_instance_class      = "db.t3.medium"
db_multi_az            = true
db_deletion_protection = true
db_skip_final_snapshot = false

app_secret_json = "{\"APP_ENV\":\"prod\",\"LOG_LEVEL\":\"warn\"}"
