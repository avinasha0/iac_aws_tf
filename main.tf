resource "aws_vpc" "tf_vpc" {
        cidr_block = var.cidr_block
}
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.tf_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}
resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.tf_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.tf_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    } 
}

resource "aws_route_table_association" "RTA1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "RTA2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "tf_sg" {
  name        = "web SG"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    tags = {
      Name="web-sg"
    }
}


resource "aws_instance" "tf_webserver1" {
    ami="ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.tf_sg.id]
    subnet_id = aws_subnet.sub1.id
    user_data = base64encode(file("userdata.sh"))
}

