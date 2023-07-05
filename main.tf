provider "aws" {
  region     = "us-west-2"

}

# create vpc
resource "aws_default_vpc" "default" {
  tags = {
    Name = "TF Default VPC"
    #cidr_block = "172.31.0.0/16"
  }
}

# create security group
resource "aws_security_group" "default" {
  name        = "sg default"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
    #cidr_blocks      = [aws_vpc.main.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "default"
  }
}

# create sg allow ssh
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_default_vpc.default.cidr_block]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = tostring(aws_security_group.default.id)
}


# create ec2 instance
 resource "aws_instance" "tf_flask" {
   ami           = "ami-0ae49954dfb447966"
   instance_type = "t2.micro"
   key_name = "tfKeyPair"
 
   tags = {
     Name = "tfFlask"
   }
 
   depends_on = [ aws_default_vpc.default ]
 
 }