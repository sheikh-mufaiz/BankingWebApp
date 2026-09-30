# Generate dynamic Ansible inventory files
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible_inventory.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.ini.tpl", {
    ansible_server_ip = aws_instance.ansible_server.public_ip
    jenkins_master_ip = aws_instance.jenkins_master.public_ip
    jenkins_slave_ip  = aws_instance.jenkins_slave.public_ip
    monitoring_ip     = aws_instance.monitoring_server.public_ip
  })
}

resource "local_file" "ansible_folder_inventory" {
  filename        = "${path.module}/ansible/inventory.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.ini.tpl", {
    ansible_server_ip = aws_instance.ansible_server.public_ip
    jenkins_master_ip = aws_instance.jenkins_master.public_ip
    jenkins_slave_ip  = aws_instance.jenkins_slave.public_ip
    monitoring_ip     = aws_instance.monitoring_server.public_ip
  })
}

