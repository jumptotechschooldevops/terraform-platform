locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  common_tags          = local.common_tags
}

resource "aws_security_group" "alb" {
  name   = "${local.name_prefix}-alb-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name   = "${local.name_prefix}-app-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name   = "${local.name_prefix}-db-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "alb" {
  source = "../../modules/alb"

  name    = "${local.name_prefix}-alb"
  vpc_id  = module.network.vpc_id
  subnets = module.network.public_subnets
  sg_ids  = [aws_security_group.alb.id]
}

module "app" {
  source = "../../modules/app"

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnets       = module.network.private_subnets
  tg            = [module.alb.tg]
  desired       = var.desired_capacity
  min           = var.min_size
  max           = var.max_size
}

module "rds" {
  source = "../../modules/rds"

  name           = "${local.name_prefix}-db"
  instance_class = var.db_instance_class
  username       = var.db_username
  subnets        = module.network.private_subnets
  sg             = [aws_security_group.db.id]
}

module "dynamodb" {
  source = "../../modules/dynamodb"
  name   = "${local.name_prefix}-table"
}

module "secrets" {
  source = "../../modules/secrets"
  name   = "${local.name_prefix}-secret"
  value  = var.app_secret_json
}
