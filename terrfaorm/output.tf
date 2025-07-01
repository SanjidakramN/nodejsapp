output "vpc_id" {
  value = aws_vpc.main.id
}

output "aws_public" {
  value = aws_subnet.public
}

output "aws_private" {
  value = aws_subnet.private
}
