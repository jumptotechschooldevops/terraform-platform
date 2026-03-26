output "alb_dns" {
  value = module.alb.dns
}

output "asg_name" {
  value = module.app.asg_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
