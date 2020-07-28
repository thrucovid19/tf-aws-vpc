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
  depends_on = ["aws_internet_gateway.default"]

  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name        = "gwNAT",
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
      Name        = "PrivateRouteTable",
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
      Name        = "PublicSubnet",
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
      Name        = "ManagementSubnet",
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
      Name        = "PrivateSubnet",
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