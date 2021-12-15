resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "private-subnet" {
  cidr_block = var.private_subnet_cidr
  vpc_id     = aws_vpc.main.id
}

resource "aws_subnet" "public-subnet" {
  cidr_block = var.public_subnet_cidr
  vpc_id     = aws_vpc.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = aws_subnet.public-subnet.cidr_block
  network_interface_id = aws_instance.nat.primary_network_interface_id
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    action     = "allow"
    rule_no    = 100
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    action     = "allow"
    rule_no    = 100
    cidr_block = "0.0.0.0/0"
  }
}

// nat gateway ec2 instance 
resource "aws_instance" "nat" {
  ami           = var.nat_ami 
  instance_type = "t3a.nano"
  subnet_id     = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.nat.id]
  source_dest_check = false
}

resource "aws_security_group" "nat" {
  name        = "terraform-nat-test"
  description = "terraform-nat-test"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}