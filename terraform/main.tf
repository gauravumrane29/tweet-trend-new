provider "aws" {
    region  = "ap-south-1"
}

resource "aws_instance" "devops" {
    ami           = "ami-02b8269d5e85954ef" 
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.devops_sg.id]
    subnet_id = aws_subnet.devops_public_subnet1.id
    key_name = "project"
    for_each = toset(["Jenkins_master", "jenkins_agent1", "ansible_host"])
    tags = {
        Name = "${each.key}"
        Environment = "Development"
    }
}

resource "aws_security_group" "devops_sg" {
    name = "devops_sg"
    description = "Security group for DevOps instance"
    vpc_id = aws_vpc.devops_vpc.id
    tags = {
        Name = "DevOpsSecurityGroup"
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {    
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}

resource "aws_vpc" "devops_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "DevOpsVPC"
    }
}

resource "aws_subnet" "devops_public_subnet1" {
    vpc_id            = aws_vpc.devops_vpc.id
    cidr_block       = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "DevOpsPublicSubnet1"
    }
} 

resource "aws_subnet" "devops_private_subnet2" {
    vpc_id            = aws_vpc.devops_vpc.id
    cidr_block       = "10.0.2.0/24"
    map_public_ip_on_launch = false
    availability_zone = "ap-south-1b"
    tags = {
        Name = "DevOpsPrivateSubnet2"
    }
} 

resource "aws_route_table" "devops_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_igw.id
    }
    tags = {
        Name = "DevOpsRouteTable"
    }
}
resource "aws_route_table_association" "devops_rta_public_subnet1" {
    subnet_id      = aws_subnet.devops_public_subnet1.id
    route_table_id = aws_route_table.devops_route_table.id
}

resource "aws_internet_gateway" "devops_igw" {
    vpc_id = aws_vpc.devops_vpc.id
    tags = {
        Name = "DevOpsIGW"
    }

}