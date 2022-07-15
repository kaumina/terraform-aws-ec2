output "security_group" {
  value = aws_security_group.allow_80.id
}
output "ec2_public_ip" {
  value = aws_instance.amazon-linux.public_ip
}
output "ec2_instance_id" {
  value = aws_instance.amazon-linux.id
}
output "web_url" {
  value = "http://${aws_instance.amazon-linux.public_ip}"
}