variable "aws_region" {
  description = "AWS Region for infrastructure deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment identifier (dev/qa/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones to distribute subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "key_name" {
  description = "Name of the AWS Key Pair"
  type        = string
  default     = "banking_web_app_key"
}

# --- Instance Types (AWS Free Tier: t2.micro or t3.micro) ---
variable "ansible_server_instance_type" {
  description = "EC2 instance type for Ansible Controller server"
  type        = string
  default     = "t3.micro"
}

variable "jenkins_master_instance_type" {
  description = "EC2 instance type for Jenkins Master server"
  type        = string
  default     = "t3.micro"
}

variable "jenkins_slave_instance_type" {
  description = "EC2 instance type for Jenkins Slave / Build Server"
  type        = string
  default     = "t3.micro"
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for Dedicated Monitoring server (Prometheus & Grafana)"
  type        = string
  default     = "t3.micro"
}

# --- Storage Sizes (Free Tier: 30 GB total across all instances; 8 GB is the Ubuntu AMI minimum) ---
variable "ansible_server_volume_size" {
  description = "Root EBS volume size in GB for Ansible Controller (min 8 GB for Ubuntu AMI)"
  type        = number
  default     = 8
}

variable "jenkins_master_volume_size" {
  description = "Root EBS volume size in GB for Jenkins Master (min 8 GB for Ubuntu AMI)"
  type        = number
  default     = 8
}

variable "jenkins_slave_volume_size" {
  description = "Root EBS volume size in GB for Jenkins Slave (min 8 GB for Ubuntu AMI)"
  type        = number
  default     = 8
}

variable "monitoring_volume_size" {
  description = "Root EBS volume size in GB for Dedicated Monitoring Server (min 8 GB for Ubuntu AMI)"
  type        = number
  default     = 8
}

variable "allowed_ssh_cidr" {
  description = "CIDR block permitted to SSH directly to instances"
  type        = string
  default     = "0.0.0.0/0"
}
