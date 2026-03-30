output "alb_dns" {
  value = module.alb.alb_dns_name   
}

output "asg_name" {
  value = module.app.asg_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint   
}
