output "jenkins-ip" {
    value = aws_instance.jenkins-server.public_ip
}

output "nexus-ip" {
    value = aws_instance.nexus-server.public_ip
}

output "sonar-ip" {
    value = aws_instance.sonarqube-server.public_ip
}
