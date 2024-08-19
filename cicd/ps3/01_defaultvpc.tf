##### VPC
resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}


##### Subnet
resource "aws_subnet" "A" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.31.32.0/20"
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "B" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.31.16.0/20"
  availability_zone = "ap-northeast-2b"
}

resource "aws_subnet" "C" {
  vpc_id = aws_vpc.main.id
  cidr_block = "172.31.0.0/20"
  availability_zone = "ap-northeast-2c"
}


##### IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}


##### RTB
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "main" {
  route_table_id = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}


##### RTB Association
resource "aws_route_table_association" "A" {
  subnet_id = aws_subnet.A.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "B" {
  subnet_id = aws_subnet.B.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "C" {
  subnet_id = aws_subnet.C.id
  route_table_id = aws_route_table.main.id
}