# NAT stuff for EKS cluster
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_default_subnet.public_subnet1.id

  tags = {
    Name = "nat-gateway"
  }
}
