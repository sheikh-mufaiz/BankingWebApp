#!/bin/bash
set -e

# Update packages
apt-get update -y
apt-get upgrade -y

# Install prerequisites
apt-get install -y software-properties-common curl git unzip python3 python3-pip

# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

echo "Ansible Controller initialization completed successfully."
