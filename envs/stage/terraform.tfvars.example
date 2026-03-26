aws_region        = "us-east-2"
project_name      = "terraform-platform"
environment       = "stage"
owner             = "devops"

vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]

instance_type    = "t3.micro"
desired_capacity = 1
min_size         = 1
max_size         = 2

key_name = null

allowed_http_cidrs = ["0.0.0.0/0"]

db_name                = "appdb"
db_username            = "appadmin"
db_instance_class      = "db.t3.micro"
db_multi_az            = false
db_deletion_protection = false
db_skip_final_snapshot = true

app_secret_json = "{\"APP_ENV\":\"stage\",\"LOG_LEVEL\":\"info\"}"
