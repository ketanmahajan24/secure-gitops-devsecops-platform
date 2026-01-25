resource "aws_security_group" "k8s_master" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_security_group" "k8s_worker" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [var.my_ip]
  }
  
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_security_group" "cicd" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
resource "aws_security_group" "mongodb-server" {
  name   = "mongodb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
