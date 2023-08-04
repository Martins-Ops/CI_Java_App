resource "aws_security_group" "Jenkins-SG" {
  name        = "Jenkins-SG"
  vpc_id      = aws_vpc.VPC.id

  # Inbound rule for IPv4
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  # Inbound rule for IPv6
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
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

# Allow inbound traffic from "SonarQube-SG" to "Jenkins-SG" on port 8080
resource "aws_security_group_rule" "sonarqube_to_jenkins" {
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  source_security_group_id = aws_security_group.SonarQube-SG.id
  security_group_id        = aws_security_group.Jenkins-SG.id
}

resource "aws_key_pair" "javaapp-key" {
    key_name = "javaapp-key"
    public_key = file(var.public_key_location)
}
resource "aws_instance" "jenkins-server" {
    ami = var.amijenkins
    instance_type = var.instance_type
    subnet_id     = aws_subnet.PublicSubnet1.id
    vpc_security_group_ids = [aws_security_group.Jenkins-SG.id]
    availability_zone      = data.aws_availability_zones.available.names[0]
    associate_public_ip_address = true
    key_name = aws_key_pair.javaapp-key.key_name
    user_data = file("../jenkins.sh")
    depends_on = [
        aws_key_pair.javaapp-key
    ]
    tags = {
        Name = "jenkins-server"
    }
}

