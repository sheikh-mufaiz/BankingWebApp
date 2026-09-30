# ==========================================
# Look up Latest Ubuntu 22.04 LTS AMI
# ==========================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==========================================
# 0. Ansible Controller Server
# ==========================================
resource "aws_instance" "ansible_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ansible_server_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
  user_data              = file("${path.module}/scripts/user_data_ansible.sh")

  root_block_device {
    volume_size           = var.ansible_server_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Ansible_Server"
    Role = "Ansible_Controller"
  }
}

# ==========================================
# 1. Jenkins Master (VM1)
# ==========================================
resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.jenkins_master_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_size           = var.jenkins_master_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Jenkins_Master"
    Role = "Jenkins_Master"
  }
}

# ==========================================
# 2. Jenkins Slave / Build Server (VM2)
# ==========================================
resource "aws_instance" "jenkins_slave" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.jenkins_slave_instance_type
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.jenkins_slave_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_size           = var.jenkins_slave_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Jenkins_SlaveNode_Build_Server"
    Role = "Jenkins_Slave"
  }
}

# ==========================================
# 3. Dedicated Monitoring Server
# ==========================================
resource "aws_instance" "monitoring_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.monitoring_instance_type
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_size           = var.monitoring_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Dedicated_Monitoring_Server"
    Role = "Monitoring"
  }
}
