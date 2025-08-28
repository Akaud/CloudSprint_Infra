output "db_cluster_endpoint" {
  description = "The endpoint of the PostgreSQL cluster."
  value       = aws_rds_cluster.postgres_cluster.endpoint
}

output "db_cluster_reader_endpoint" {
  description = "The reader endpoint of the PostgreSQL cluster."
  value       = aws_rds_cluster.postgres_cluster.reader_endpoint
}

output "db_instance_endpoint" {
  description = "The endpoint of the PostgreSQL instance."
  value       = aws_rds_cluster_instance.postgres_instance.endpoint
}

output "db_proxy_endpoint" {
  description = "The RDS Proxy endpoint for connection pooling."
  value       = aws_db_proxy.db_proxy.endpoint
}

output "db_name" {
  description = "The name of the provisioned database."
  value       = aws_rds_cluster.postgres_cluster.database_name
}

output "cluster_identifier" {
  description = "The cluster identifier."
  value       = aws_rds_cluster.postgres_cluster.cluster_identifier
}
