resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.az1
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-subnet"
    }
}

resource "aws_subnet" "public_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_2
    availability_zone = var.az2
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-subnet-2"
    } 
}