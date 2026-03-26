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
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  common_tags          = local.common_tags
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP"
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "App security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "HTTP from ALB"
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "DB security group"
  vpc_id      = module.network.vpc_id

  ingress {
    description     = "Postgres from app"
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

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
  })
}

module "alb" {
  source = "../../modules/alb"

  name               = "${local.name_prefix}-alb"
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]
  target_port        = 80
  health_check_path  = "/"
  common_tags        = local.common_tags
}

module "app" {
  source = "../../modules/app"

  name_prefix        = local.name_prefix
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  subnet_ids         = module.network.private_subnet_ids
  security_group_ids = [aws_security_group.app.id]
  target_group_arns  = [module.alb.target_group_arn]
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  key_name           = var.key_name

  user_data = <<-EOT
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>${var.project_name} - ${var.environment}</h1>" > /usr/share/nginx/html/index.html
              EOT

  common_tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  identifier              = "${local.name_prefix}-postgres"
  db_name                 = var.db_name
  username                = var.db_username
  instance_class          = var.db_instance_class
  subnet_ids              = module.network.private_subnet_ids
  security_group_ids      = [aws_security_group.db.id]
  multi_az                = var.db_multi_az
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  common_tags             = local.common_tags
}

module "app_table" {
  source = "../../modules/dynamodb"

  table_name = "${local.name_prefix}-app-table"
  hash_key   = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  common_tags = local.common_tags
}

module "app_secret" {
  source = "../../modules/secrets"

  name          = "${local.name_prefix}/app/config"
  description   = "Application config secret"
  secret_string = var.app_secret_json
  common_tags   = local.common_tags
}
