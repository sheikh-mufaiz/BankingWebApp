# AWS Infrastructure Provisioning with Terraform
## Capstone Project: BankingWebApp (FundMe)

This Terraform project automates the entire AWS cloud infrastructure for the **FundMe Banking & Finance Domain DevOps Pipeline**.

---

## 🏗️ Architecture & Server Fleet

All instances are provisioned on **Ubuntu 22.04 LTS** in a custom VPC with public subnets across multiple Availability Zones:

| Server Name | Tag | Type | EBS Storage | Purpose | Key Ports |
|-------------|-----|------|-------------|---------|-----------|
| **Ansible Controller** | `Ansible_Server` | `t2.micro` | 8 GB gp3 | Runs Ansible playbooks, config management, CLI | SSH (22) |
| **Jenkins Master** | `Jenkins_Master` | `t2.micro` | 8 GB gp3 | CI/CD Pipeline Controller & Job Scheduler | Web UI (8080), JNLP (50000), SSH (22) |
| **Jenkins Slave** | `Jenkins_SlaveNode_Build_Server` | `t2.micro` | 8 GB gp3 | Build node: Maven, Docker image builds, tests | SSH (22) |
| **Monitoring Server** | `Dedicated_Monitoring_Server` | `t2.micro` | 8 GB gp3 | Prometheus metrics scraping & Grafana dashboards | Prometheus (9090), Grafana (3000), NodeExp (9100) |

> **Note**: Default AWS OS user is `ubuntu`, and the dedicated Ansible management user configured across all nodes is `ansibleadmin`.


---

## 🚀 Quick Start Guide

### 1. Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.3.0) installed.
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid AWS credentials:
  ```bash
  aws configure
  ```

### 2. Initialize Terraform
Run `init` to download the AWS, TLS, and Local providers:
```bash
terraform init
```

### 3. Review the Execution Plan
```bash
terraform plan
```

### 4. Provision Infrastructure
```bash
terraform apply
```
Type `yes` when prompted, or run `terraform apply -auto-approve`.

---

## 🔑 SSH Access & Ansible Inventory

- **SSH Private Key**: Automatically generated and saved in this folder as:
  ```
  banking_key.pem
  ```
- **Connecting via SSH**:
  ```bash
  ssh -i banking_key.pem ubuntu@<SERVER_PUBLIC_IP>
  ```
- **Ansible Inventory**: Automatically generated as `ansible_inventory.ini` in the root folder and `ansible/inventory.ini` inside the `ansible/` directory.

---

## ⚙️ Automated Tool Configuration with Ansible

The [`ansible/`](file:///c:/Users/smufa/Desktop/resource_provision/ansible) directory contains automated, production-grade roles and playbooks to configure all required software across the fleet.

### Fleet Tool Summary

| Server Node | Installed Tools & Configuration |
| :--- | :--- |
| **All Fleet Nodes** | • Essential packages (`curl`, `git`, `htop`, etc.)<br>• **2 GB Swapfile** (prevents OOM on `t3.micro`)<br>• **Prometheus Node Exporter** (port `9100`) |
| **Jenkins Master** | • **OpenJDK 21**<br>• **Jenkins LTS** with tuned JVM memory options (`-Xms256m -Xmx512m`)<br>• Prints unlock admin password at the end of execution |
| **Jenkins Slave** | • **OpenJDK 21** (Jenkins Agent runtime prerequisite)<br>• **OpenJDK 17** (Project build requirement)<br>• **Maven 3** & **Git**<br>• **Docker CE Engine** (`ubuntu` added to `docker` group)<br>• **Trivy** vulnerability scanner<br>• **AWS CLI v2** |
| **Monitoring Server** | • **Prometheus** (configured to auto-scrape all nodes on `9100`)<br>• **Grafana** (port `3000`) with auto-provisioned Prometheus datasource |

---

### Running the Ansible Playbooks

#### Option 1: Running from the Dedicated Ansible Controller (`Ansible_Server`)

1. Copy the `ansible` folder to the Ansible Controller:
   ```bash
   scp -i banking_key.pem -r ansible ubuntu@<ANSIBLE_SERVER_IP>:~/
   ```
2. SSH into the Ansible Controller:
   ```bash
   ssh -i banking_key.pem ubuntu@<ANSIBLE_SERVER_IP>
   ```
3. Enter the `ansible` directory:
   ```bash
   cd ~/ansible
   ```
4. Test connectivity across all nodes using the `ansibleadmin` user:
   ```bash
   ansible all -i inventory.ini -m ping
   ```
5. Run the master playbook to configure all tools:
   ```bash
   ansible-playbook -i inventory.ini site.yml
   ```

#### Option 2: Running Directly from Local Machine (WSL / Linux / Git Bash)

```bash
cd ansible
chmod 400 ../banking_key.pem
ansible-playbook -i inventory.ini site.yml
```
*(Or run `./run_playbook.sh site.yml`)*

#### Modular Playbooks

If you only want to provision or re-run a specific server role:
- `ansible-playbook -i inventory.ini playbooks/ping_all.yml` (Health check)
- `ansible-playbook -i inventory.ini playbooks/setup_common.yml` (Swap + Node Exporter)
- `ansible-playbook -i inventory.ini playbooks/setup_jenkins_master.yml` (Jenkins Master)
- `ansible-playbook -i inventory.ini playbooks/setup_jenkins_slave.yml` (Build Slave)
- `ansible-playbook -i inventory.ini playbooks/setup_monitoring.yml` (Prometheus + Grafana)

---

## 🌐 Web Dashboards (After Tools are Configured)

- **Jenkins UI**: `http://<JENKINS_MASTER_IP>:8080`
- **Prometheus UI**: `http://<MONITORING_SERVER_IP>:9090`
- **Grafana UI**: `http://<MONITORING_SERVER_IP>:3000`

---

## ⏸️ Pausing Servers (Save Costs Without Deleting Data)

When you finish practicing and want to shut down servers without losing any installed tools or configurations:

- **Shut Down (Stop) All Servers:**
  ```powershell
  .\scripts\stop_all.ps1
  ```
  * Compute charges immediately drop to **$0.00/hr**.
  * Dynamic public IPv4 charges drop to **$0.00/hr**.
  * All files, configurations, and tools remain safely stored on the EBS disks (~$0.16/month total).

- **Resume (Start) All Servers:**
  ```powershell
  .\scripts\start_all.ps1
  ```
  * Powers on all servers.
  * Automatically fetches the newly assigned public IPs.
  * Automatically updates `ansible_inventory.ini` and prints updated SSH/Web URLs!

---

## 🧹 Permanent Deletion (Tear Down Everything)

Only run this when you want to permanently delete all infrastructure (VPC, subnets, instances, and EBS disks):
```bash
terraform destroy -auto-approve
```
