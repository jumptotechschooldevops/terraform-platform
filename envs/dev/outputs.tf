output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "app_asg_name" {
  value = module.app.asg_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  value = module.rds.master_user_secret_arn
}

output "app_table_name" {
  value = module.app_table.table_name
}

output "app_secret_arn" {
  value = module.app_secret.secret_arn
}
