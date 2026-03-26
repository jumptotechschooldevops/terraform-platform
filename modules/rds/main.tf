resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                   = var.identifier
  db_name                      = var.db_name
  username                     = var.username
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = var.security_group_ids
  multi_az                     = var.multi_az
  publicly_accessible          = false
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  manage_master_user_password  = true
  backup_retention_period      = 7
  auto_minor_version_upgrade   = true
  storage_encrypted            = true

  tags = merge(var.common_tags, {
    Name = var.identifier
  })
}
