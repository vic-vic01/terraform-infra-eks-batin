output "vpc_id" {
  description = "id of the vpc"
  value       = aws_vpc.custom-vpc.id
}

output "public_subnet_ids" {
  description = "public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "private subnet IDs"
  value       = aws_subnet.private[*].id
}