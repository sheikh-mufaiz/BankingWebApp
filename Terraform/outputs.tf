# ==========================================
# Web Management URLs
# ==========================================
output "jenkins_url" {
  description = "Jenkins Web UI URL"
  value       = "http://${aws_instance.jenkins_master.public_ip}:8080"
}

output "prometheus_url" {
  description = "Prometheus Web UI URL"
  value       = "http://${aws_instance.monitoring_server.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana Web UI Dashboard URL"
  value       = "http://${aws_instance.monitoring_server.public_ip}:3000"
}

# ==========================================
# Server Public IPs
# ==========================================
output "ansible_server_public_ip" {
  description = "Public IP of Ansible Controller"
  value       = aws_instance.ansible_server.public_ip
}

output "jenkins_master_public_ip" {
  description = "Public IP of Jenkins Master"
  value       = aws_instance.jenkins_master.public_ip
}

output "jenkins_slave_public_ip" {
  description = "Public IP of Jenkins Slave Build Server"
  value       = aws_instance.jenkins_slave.public_ip
}


output "monitoring_server_public_ip" {
  description = "Public IP of Dedicated Monitoring Server"
  value       = aws_instance.monitoring_server.public_ip
}

# ==========================================
# Server Instance IDs
# ==========================================
output "instance_ids" {
  description = "IDs of all EC2 instances"
  value = {
    ansible_server    = aws_instance.ansible_server.id
    jenkins_master    = aws_instance.jenkins_master.id
    jenkins_slave     = aws_instance.jenkins_slave.id
    monitoring_server = aws_instance.monitoring_server.id
  }
}

# ==========================================
# SSH Connection Commands
# ==========================================
output "ssh_commands" {
  description = "Direct SSH login commands using the generated key"
  value = {
    ansible_controller = "ssh -i banking_key.pem ubuntu@${aws_instance.ansible_server.public_ip}"
    jenkins_master     = "ssh -i banking_key.pem ubuntu@${aws_instance.jenkins_master.public_ip}"
    jenkins_slave      = "ssh -i banking_key.pem ubuntu@${aws_instance.jenkins_slave.public_ip}"
    monitoring_server  = "ssh -i banking_key.pem ubuntu@${aws_instance.monitoring_server.public_ip}"
  }
}

output "private_key_file" {
  description = "Path to the generated SSH private key"
  value       = "${path.module}/banking_key.pem"
}

output "ansible_inventory_file" {
  description = "Path to the generated Ansible inventory file"
  value       = "${path.module}/ansible_inventory.ini"
}
