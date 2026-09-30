[ansible_controller]
ansible-node ansible_host=${ansible_server_ip}

[jenkins_master]
jenkins-master-node ansible_host=${jenkins_master_ip}

[jenkins_slave]
jenkins-slave-node ansible_host=${jenkins_slave_ip}

[monitoring]
monitoring-node ansible_host=${monitoring_ip}

[all:vars]
ansible_user=ansibleadmin

