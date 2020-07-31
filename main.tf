# Create a VPC 

resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = var.name,
      Environment = var.environment
    },
    var.tags
  )
}

# Creates an Internet gateway 

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = "gwInternet",
      Environment = var.environment
    },
    var.tags
  )
}

# Create a NAT gateway along with its EIP

resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)

  vpc = true
}

resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]

  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name        = "gwNAT ${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

# Create a private route table

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = "PrivateRouteTable ${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "private" {
  count = length(var.private_subnet_cidr_blocks)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[count.index].id
}

# Create a public route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = "PublicRouteTable",
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a management route table

resource "aws_route_table" "management" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    {
      Name        = "ManagementRouteTable",
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "management" {
  route_table_id         = aws_route_table.management.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a public subnet

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "PublicSubnet ${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

# Create a management subnet

resource "aws_subnet" "management" {
  count = length(var.management_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.management_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "ManagementSubnet ${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

# Create a private subnet 

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "PrivateSubnet ${count.index}",
      Environment = var.environment
    },
    var.tags
  )
}

# Route table association for all subnets

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "management" {
  count = length(var.management_subnet_cidr_blocks)

  subnet_id      = aws_subnet.management[count.index].id
  route_table_id = aws_route_table.management.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create a public security group

resource "aws_security_group" "public" {
  name        = "${var.name} Firewall-Public"
  description = "Allow inbound applications from the internet"
  vpc_id      = aws_vpc.default.id
}

resource "aws_security_group_rule" "public" {
  for_each          = local.public_sg_rules
  security_group_id = aws_security_group.public.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [each.value.cidr_blocks]
}

# Create a management security group

resource "aws_security_group" "mgmt" {
  name        = "${var.name} Firewall-Mgmt"
  description = "Allow inbound management to the firewall"
  vpc_id      = aws_vpc.default.id
}

resource "aws_security_group_rule" "mgmt" {
  for_each          = local.management_sg_rules
  security_group_id = aws_security_group.mgmt.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [each.value.cidr_blocks]
}

# Create a private security group

resource "aws_security_group" "private" {
  name        = "${var.name} Firewall-Private"
  description = "Allow inbound traffic to the firewalls private interfaces"
  vpc_id      = aws_vpc.default.id
}

resource "aws_security_group_rule" "private" {
  for_each          = local.private_sg_rules
  security_group_id = aws_security_group.private.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = [each.value.cidr_blocks]
}

/*resource "aws_security_group_rule" "from_vmseries" {
  security_group_id = data.terraform_remote_state.panorama.outputs.mgmt_sg
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.default.cidr_block]
}*/

locals {
  management_sg_rules = {
    ssh-from-on-prem = {
      type        = "ingress"
      cidr_blocks = var.mgmt_subnet
      protocol    = "tcp"
      from_port   = "22"
      to_port     = "22"
    }
    https-from-on-prem = {
      type        = "ingress"
      cidr_blocks = var.mgmt_subnet
      protocol    = "tcp"
      from_port   = "443"
      to_port     = "443"
    }
    egress = {
      type        = "egress"
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
    }
  }
  public_sg_rules = {
    ingress = {
      type        = "ingress"
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
    }
    egress = {
      type        = "egress"
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
    }
  }
  private_sg_rules = {
    ingress = {
      type        = "ingress"
      cidr_blocks = aws_vpc.default.cidr_block
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
    }
    egress = {
      type        = "egress"
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
    }
  }
}