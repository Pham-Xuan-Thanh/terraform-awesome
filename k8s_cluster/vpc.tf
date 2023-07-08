# Create a VPC
resource "aws_vpc" "cluster_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "cluster-vpc"
  }
}
# provide internet access for services within VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "vpc_igw"
  }
  depends_on = [aws_vpc.cluster_vpc]
}

# public subnet(s)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cluster_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name                                           = "${var.project}-public-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }
}
# Private Subnet(s)
resource "aws_subnet" "private_subnet" {

  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_subnet_availability_zone

  tags = {
    Name                                           = "${var.project}-private-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}

# routing tabes for routing rules for access from ig to VPC
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

# Associate route table with subnet(s) for binding routing rule(s)
resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Elastic IP for VPC 
resource "aws_eip" "main" {
  vpc = true

  tags = {
    Name = "${var.project}-ngw-ip"
  }
}

# NAT Gateway: bind NAT to public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "${var.project}-ngw"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Add route to route table
resource "aws_route" "main" {
  route_table_id         = aws_vpc.cluster_vpc.default_route_table_id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

# Security group for public subnet
resource "aws_security_group" "public_sg" {
  name   = "${var.project}-Public-sg"
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "${var.project}-Public-sg"
  }
}

# Security group traffic rules
# port 443 ingress
resource "aws_security_group_rule" "sg_ingress_public_443" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
# port 80 ingress
resource "aws_security_group_rule" "sg_ingress_public_80" {
  security_group_id = aws_security_group.public_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
# all protocols, ports egress
resource "aws_security_group_rule" "sg_egress_public" {
  security_group_id = aws_security_group.public_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


# Security group for data plane (worker nodes)
resource "aws_security_group" "data_plane_sg" {
  name   = "${var.project}-Worker-sg"
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "${var.project}-Worker-sg"
  }
}

# Security group traffic rules
resource "aws_security_group_rule" "nodes" {
  description       = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.private_subnet_cidr, var.public_subnet_cidr]
}

resource "aws_security_group_rule" "nodes_inbound" {
  description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.private_subnet_cidr]
}

resource "aws_security_group_rule" "node_outbound" {
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for control plane (Master nodes)
resource "aws_security_group" "control_plane_sg" {
  name   = "${var.project}-ControlPlane-sg"
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "${var.project}-ControlPlane-sg"
  }
}

# Security group traffic rules
resource "aws_security_group_rule" "control_plane_inbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.private_subnet_cidr, var.public_subnet_cidr]
}

resource "aws_security_group_rule" "control_plane_outbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}