output "db_cluster_endpoint" {
  description = "The endpoint of the PostgreSQL cluster."
  value       = aws_rds_cluster.postgres_cluster.endpoint
}

output "db_proxy_endpoint" {
  description = "The endpoint of the RDS Proxy for connection pooling."
  value       = aws_db_proxy.db_proxy.endpoint
}

output "db_name" {
  description = "The name of the provisioned database."
  value       = aws_rds_cluster.postgres_cluster.database_name
}
