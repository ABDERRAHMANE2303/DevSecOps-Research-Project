###################################################################
### VPC Core (VPC + DNS)
###################################################################
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true  # true only cuz ill use a bastion host 
    tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

###################################################################
# Public Network Layer (Subnets, IGW, Public Routes)
###################################################################

# 2 Public Subnets
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in local.public_subnet_cidrs :
    idx => { cidr = cidr, az = local.azs[idx] }
  }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${each.key}"
    Tier = "public"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Public routing table + it's associations 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

###################################################################
# Egress Layer (NAT Gateways + EIPs)
###################################################################

# EIP
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${each.key}"
  })
}

# NAT
resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-${each.key}"
  })
  depends_on = [aws_internet_gateway.igw]
}


###################################################################
# Private Network Layer (Subnets, Private Routes)
###################################################################

# 4 Private subnets
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in local.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = local.azs[idx % length(local.azs)]
    }
  }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${each.key}"
    Tier = "private"
  })
}

# Routing tables & their associations
resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.nat
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[tonumber(each.key) % length(local.azs)].id
}