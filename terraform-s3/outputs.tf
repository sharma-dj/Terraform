output "public_instance_ip" {
  value = aws_instance.ec2-instance.public_ip
}
output "public_instance_dns" {
  value = aws_instance.ec2-instance.public_dns
}
output "s3_arn" {
  value       = aws_s3_bucket.example.arn
  description = "S3 arn"
}
