resource "aws_instance" "master" {
  ami = var.ami_id
  instance_type = "t2.medium"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.k8s_master.id]
  key_name = aws_key_pair.key.key_name
  tags = { Name = "k8s-master" }
}

resource "aws_instance" "worker1" {
  ami = var.ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.k8s_worker.id]
  key_name = aws_key_pair.key.key_name
  tags = { Name = "worker1" }
}

resource "aws_instance" "worker2" {
  ami = var.ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.k8s_worker.id]
  key_name = aws_key_pair.key.key_name
  tags = { Name = "worker2" }
}

resource "aws_instance" "cicd" {
  ami = var.ami_id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.cicd.id]
  key_name = aws_key_pair.key.key_name
  tags = { Name = "cicd-devops-node " }
}
