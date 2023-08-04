locals {
  env_name  = "java-app"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "VPC" {
  cidr_block       =  var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = local.env_name
  }
}

resource "aws_internet_gateway" "gw" {
  tags = {
    Name = local.env_name
  }
}

resource "aws_internet_gateway_attachment" "gw-attach" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.VPC.id
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.cidr_block_pub1 
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.cidr_block_pri1
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "PrivateSubnet1"
  }
}

# resource "aws_eip" "NatEIP1" {
#   domain       = "vpc" 
#   depends_on   = [aws_internet_gateway.gw]
# }

# resource "aws_nat_gateway" "NatGw1" {
#   allocation_id = aws_eip.NatEIP1.allocation_id
#   subnet_id     = aws_subnet.PublicSubnet1.id
# }


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.VPC.id

  tags = {
  Name = "java-app route table"
}
}

resource "aws_route" "route1" {
  route_table_id            = aws_route_table.rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
  depends_on                = [aws_internet_gateway_attachment.gw-attach]
}

resource "aws_route_table_association" "rt_ass" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.rt.id
}

# resource "aws_route_table" "pri-rt1" {
#   vpc_id = aws_vpc.VPC.id

#   tags = {
#   Name = "java-app route table"
# }
# }

# resource "aws_route" "pri-route" {
#   route_table_id            = aws_route_table.pri-rt1.id
#   destination_cidr_block    = "0.0.0.0/0"
#   # nat_gateway_id             = aws_nat_gateway.NatGw1.id
#   depends_on                = [aws_internet_gateway_attachment.gw-attach]
# }

# resource "aws_route_table_association" "pri_rt_ass" {
#   subnet_id      = aws_subnet.PrivateSubnet1.id
#   route_table_id = aws_route_table.pri-rt1.id
# }

