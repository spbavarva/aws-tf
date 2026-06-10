# Creating VPC

resource "aws_vpc" "primary_vpc" {
  cidr_block           = var.vpc_cidr_blocks.primary
  provider             = aws.primary
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Primary-VPC"
  }
}

resource "aws_vpc" "secondary_vpc" {
  cidr_block           = var.vpc_cidr_blocks.secondary
  provider             = aws.secondary
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Secondary-VPC"
  }
}

# Creating Subnets

resource "aws_subnet" "primary_subnet" {
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.subnet_cidr_blocks.primary
  availability_zone       = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Primary-Subnet"
    Environment = var.environment
  }
}

resource "aws_subnet" "secondary_subnet" {
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary_vpc.id
  cidr_block              = var.subnet_cidr_blocks.secondary
  availability_zone       = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Secondary-Subnet"
    Environment = var.environment
  }
}

# Creating Internet Gateways

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id
  tags = {
    Name        = "Primary-IGW"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id
  tags = {
    Name        = "Secondary-IGW"
    Environment = var.environment
  }
}

# Creating Route Tables

resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  tags = {
    Name        = "Primary-Route-Table"
    Environment = var.environment
  }
}

resource "aws_route_table" "secondary_rt" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name        = "Secondary-Route-Table"
    Environment = var.environment
  }
}

# Creating Route Associations

resource "aws_route_table_association" "primary_rt_association" {
  provider       = aws.primary
  route_table_id = aws_route_table.primary_rt.id
  subnet_id      = aws_subnet.primary_subnet.id
}

resource "aws_route_table_association" "secondary_rt_association" {
  provider       = aws.secondary
  route_table_id = aws_route_table.secondary_rt.id
  subnet_id      = aws_subnet.secondary_subnet.id
}

# Creating VPC Peering Connection

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider    = aws.primary
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = var.regions.secondary

  auto_accept = false

  tags = {
    Name        = "Primary-to-Secondary"
    Environment = var.environment
  }
}

resource "aws_vpc_peering_connection_accepter" "accept" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  auto_accept = true

  tags = {
    Name        = "Primary-to-Secondary-Accepter"
    Environment = var.environment
  }
}

# Creating Routes

resource "aws_route" "primary-route-to-secondary" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_rt.id
  destination_cidr_block    = aws_vpc.secondary_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.accept]
}

resource "aws_route" "secondary-route-to-primary" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_rt.id
  destination_cidr_block    = aws_vpc.primary_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.accept]
}

#Creating Security Groups

resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  vpc_id      = aws_vpc.primary_vpc.id
  name        = "primary-vpc-sg"
  description = "Security group for primary VPC"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.secondary_vpc.cidr_block]
    description = "Allow ICMP from secondary VPC"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.secondary_vpc.cidr_block]
    description = "Allow TCP from secondary VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "Primary-SG"
    Environment = var.environment
  }
}

resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  vpc_id      = aws_vpc.secondary_vpc.id
  name        = "secondary-vpc-sg"
  description = "Security group for secondary VPC"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from anywhere"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.primary_vpc.cidr_block]
    description = "Allow ICMP from primary VPC"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.primary_vpc.cidr_block]
    description = "Allow TCP from primary VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "Secondary-SG"
    Environment = var.environment
  }
}

# Creating EC2 Instances

resource "aws_instance" "primary_ec2" {
  provider        = aws.primary
  ami             = data.aws_ami.primary_ami.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.primary_subnet.id
  security_groups = [aws_security_group.primary_sg.id]
  key_name        = var.primary_key_name

  user_data = local.primary_user_data

  tags = {
    Name        = "Primary-EC2"
    Environment = var.environment
  }

  depends_on = [aws_vpc_peering_connection_accepter.accept]
}

resource "aws_instance" "secondary_ec2" {
  provider        = aws.secondary
  ami             = data.aws_ami.secondary_ami.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.secondary_subnet.id
  security_groups = [aws_security_group.secondary_sg.id]
  key_name        = var.secondary_key_name

  user_data = local.secondary_user_data

  tags = {
    Name        = "Secondary-EC2"
    Environment = var.environment
  }

  depends_on = [aws_vpc_peering_connection_accepter.accept]
}
