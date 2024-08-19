### Private
resource "aws_subnet" "private_A" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.31.64.0/20"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "wsi-private-a"
  }
}

### EIP
resource "aws_eip" "nat_A" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "natgw_A" {
  allocation_id = aws_eip.nat_A.id
  subnet_id = aws_subnet.A.id
  tags = {
    Name = "wsi-natgw-a"
  }
}

##### RTB 생성 #################################################################
resource "aws_route_table" "private_A" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "wsi-private-a-rt"
  }
}

##### RTB Rule 지정 ############################################################
resource "aws_route" "private_A" {
  route_table_id = aws_route_table.private_A.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw_A.id
}

##### RTB Association ##########################################################
### Private
resource "aws_route_table_association" "private_A" {
  subnet_id = aws_subnet.private_A.id
  route_table_id = aws_route_table.private_A.id
}