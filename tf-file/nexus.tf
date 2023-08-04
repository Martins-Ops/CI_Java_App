resource "aws_security_group" "Nexus-SG" {
  name        = "Nexus-SG"
  vpc_id      = aws_vpc.VPC.id

  # Inbound rule for IP
  ingress {
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
# Allow inbound traffic from "Jenkins-SG" to "Nexus-SG" on port 8080
resource "aws_security_group_rule" "jenkins_to_nexus" {
  type        = "ingress"
  from_port   = 8081
  to_port     = 8081
  protocol    = "tcp"
  source_security_group_id = aws_security_group.Jenkins-SG.id
  security_group_id        = aws_security_group.Nexus-SG.id
}
resource "aws_instance" "nexus-server" {
    ami = var.amijenkins
    instance_type = "t2.xlarge"
    subnet_id     = aws_subnet.PublicSubnet1.id
    vpc_security_group_ids = [aws_security_group.Nexus-SG.id]
    availability_zone      = data.aws_availability_zones.available.names[0]
    associate_public_ip_address = true
    key_name = aws_key_pair.javaapp-key.key_name
    user_data = file("../nexus.sh")
    depends_on = [
        aws_key_pair.javaapp-key
    ]
    tags = {
        Name = "nexus-server"
    }
}