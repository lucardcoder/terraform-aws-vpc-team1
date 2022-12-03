output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet1" {
  value = aws_subnet.public1.id
}
output "public_subnet2" {
  value = aws_subnet.public2.id
}
output "public_subnet3" {
  value = aws_subnet.public3.id
}
output "private_subnet1" {
  value = aws_subnet.private1.id
}
output "private_subnet2" {
  value = aws_subnet.private2.id
}
output "private_subnet3" {
  value = aws_subnet.private3.id
}

output "az1" {
  value = data.aws_availability_zones.all.names[0]
}
output "az2" {
  value = data.aws_availability_zones.all.names[1]
}
output "az3" {
  value = data.aws_availability_zones.all.names[2]
}