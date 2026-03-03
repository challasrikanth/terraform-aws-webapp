resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = local.igw_final_tags
  
}


resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone =  local.az_names[count.index]
    map_public_ip_on_launch = true
    
    tags = merge(
        
        local.common_tags,
        # roboshop-dev-public-us-east-1a
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        },
        var.public_subnet_tags
    )

}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]
    tags = merge(
        
        local.common_tags,
        # roboshop-dev-public-us-east-1a
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        },
        var.private_subnet_tags
    )
 }

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        local.common_tags,
        # roboshop-dev-public
        {
            Name = "${var.project}-${var.environment}-public"
        },
        var.public_route_table_tags
  )

}

resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  
}

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidr)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route.public.id
  
}

resource "aws_eip" "nat" {
    domain = "vpc"
  
}


resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id    

    depends_on = [ aws_internet_gateway.main ]
  
}




resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        local.common_tags,
        # roboshop-dev-public
        {
            Name = "${var.project}-${var.environment}-public"
        },
        var.private_route_table_tags
  )
  
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id 
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id

}

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidr)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route.private.id
}
