# Configure the AWS provider and specify the region
provider "aws" {
  region = "ap-south-1" # Mumbai region
}

# 1. Create VPC
resource "aws_vpc" "proj_vpc" {
  cidr_block           = "10.77.0.0/17"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "proj-vpc"
  }
}

# 2. Create Internet Gateway and attach to VPC
resource "aws_internet_gateway" "proj_igw" {
  vpc_id = aws_vpc.proj_vpc.id

  tags = {
    Name = "proj-igw"
  }
}

# 3. Create Subnets in different Availability Zones
# Using /24 CIDR blocks for subnets within the /17 VPC
resource "aws_subnet" "sub1_project" {
  vpc_id                  = aws_vpc.proj_vpc.id
  cidr_block              = "10.77.0.0/24"
  availability_zone       = "ap-south-1a" # Example AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "sub1-project"
  }
}

resource "aws_subnet" "sub2_project" {
  vpc_id                  = aws_vpc.proj_vpc.id
  cidr_block              = "10.77.1.0/24"
  availability_zone       = "ap-south-1b" # Example AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "sub2-project"
  }
}

resource "aws_subnet" "sub3_project" {
  vpc_id                  = aws_vpc.proj_vpc.id
  cidr_block              = "10.77.2.0/24"
  availability_zone       = "ap-south-1a" # Corrected: Changed from ap-south-1c to a supported AZ for t2.medium
  map_public_ip_on_launch = true

  tags = {
    Name = "sub3-project"
  }
}

# 4. Create Custom Route Table
resource "aws_route_table" "proj_rt" {
  vpc_id = aws_vpc.proj_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proj_igw.id
  }

  tags = {
    Name = "proj-rt"
  }
}

# 5. Associate Subnets with the Custom Route Table
resource "aws_route_table_association" "sub1_assoc" {
  subnet_id      = aws_subnet.sub1_project.id
  route_table_id = aws_route_table.proj_rt.id
}

resource "aws_route_table_association" "sub2_assoc" {
  subnet_id      = aws_subnet.sub2_project.id
  route_table_id = aws_route_table.proj_rt.id
}

resource "aws_route_table_association" "sub3_assoc" {
  subnet_id      = aws_subnet.sub3_project.id
  route_table_id = aws_route_table.proj_rt.id
}

# 6. Create Security Groups

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins instance"
  vpc_id      = aws_vpc.proj_vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Security Group for Kubernetes Control Plane
resource "aws_security_group" "k8s_cp_sg" {
  name        = "k8s-cp-sg"
  description = "Security group for Kubernetes Control Plane"
  vpc_id      = aws_vpc.proj_vpc.id

  # TCP Ingress Rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubernetes API Server (HTTPS)"
    from_port   = 6443 # Corrected from 2443, common K8s API port
    to_port     = 6443 # Corrected from 2443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "etcd client port"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "etcd peer port"
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kube-scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kube-controller-manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Calico BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Calico VXLAN"
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # UDP Ingress Rules
  ingress {
    description = "Calico VXLAN (UDP)"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "DNS (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IP Protocol 4 (IP-in-IP) for Calico
  ingress {
    description = "IP-in-IP for Calico"
    from_port   = 0 # Applies to all ports for the specified protocol
    to_port     = 0 # Applies to all ports for the specified protocol
    protocol    = "4" # IP-in-IP protocol number
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-cp-sg"
  }
}

# Security Group for Kubernetes Nodes
resource "aws_security_group" "k8s_nodes_sg" {
  name        = "k8s-nodes-sg"
  description = "Security group for Kubernetes Worker Nodes"
  vpc_id      = aws_vpc.proj_vpc.id

  # TCP Ingress Rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Calico BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Calico VXLAN"
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "etcd client port (if nodes also run etcd)"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # UDP Ingress Rules
  ingress {
    description = "Calico VXLAN (UDP)"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "DNS (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IP Protocol 4 (IP-in-IP) for Calico
  ingress {
    description = "IP-in-IP for Calico"
    from_port   = 0
    to_port     = 0
    protocol    = "4" # IP-in-IP protocol number
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-nodes-sg"
  }
}

# 7. Create EC2 Instances

# User data script for the Jenkins instance (RedHat-based AMI)
locals {
  jenkins_user_data = <<-EOF
    #!/bin/bash
    # This script runs on the EC2 instances at launch.

    # 1. Create a new user 'ansible' with a home directory and bash shell.
    # The password for 'ansible' user is set to '<ANSIBLE_USER_PASSWORD>'.
    # This is for demonstration purposes; in production, use SSH keys for authentication.
    sudo useradd ansible -m -s /bin/bash -p $(openssl passwd -1 <ANSIBLE_USER_PASSWORD>)

    # 2. Grant 'ansible' user passwordless sudo privileges.
    # This allows the 'ansible' user to run commands with root privileges without being prompted for a password.
    echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

    # 3. Enable password authentication for SSH.
    # This sed command robustly finds and sets 'PasswordAuthentication yes',
    # handling commented lines or existing 'no' values.
    sudo sed -i -E 's/^[#[:space:]]*PasswordAuthentication[[:space:]]+(yes|no)/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # 4. Enable keyboard interactive authentication for SSH.
    # This sed command robustly finds and sets 'KeyboardInteractiveAuthentication yes',
    # handling commented lines or existing 'no' values.
    # sudo sed -i -E 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]]+(yes|no)/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

    # 5. Restart the SSH daemon to apply the changes.
    # This ensures that the new SSH configuration (including password and keyboard interactive authentication) takes effect immediately.
    sudo systemctl restart sshd
  EOF

  # User data script for Kubernetes Control Plane and Worker Nodes (Ubuntu-based AMIs)
  ubuntu_user_data = <<-EOF
    #!/bin/bash
    # This script runs on the EC2 instances at launch.

    # 1. Create a new user 'ansible' with a home directory and bash shell.
    # The password for 'ansible' user is set to '<ANSIBLE_USER_PASSWORD>'.
    # This is for demonstration purposes; in production, use SSH keys for authentication.
    sudo useradd ansible -m -s /bin/bash -p $(openssl passwd -1 <ANSIBLE_USER_PASSWORD>)

    # 2. Grant 'ansible' user passwordless sudo privileges.
    # This allows the 'ansible' user to run commands with root privileges without being prompted for a password.
    echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

    # 3. Enable password authentication for SSH.
    # This sed command robustly finds and sets 'PasswordAuthentication yes',
    # handling commented lines or existing 'no' values.
    sudo sed -i -E 's/^[#[:space:]]*PasswordAuthentication[[:space:]]+(yes|no)/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # 4. Enable keyboard interactive authentication for SSH.
    # This sed command robustly finds and sets 'KeyboardInteractiveAuthentication yes',
    # handling commented lines or existing 'no' values.
    sudo sed -i -E 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]]+(yes|no)/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

    # 5. Restart the SSH daemon to apply the changes.
    # This ensures that the new SSH configuration (including password and keyboard interactive authentication) takes effect immediately.
    sudo systemctl restart ssh
  EOF
}

resource "aws_instance" "jenkins" {
  # IMPORTANT: Replace ami-xxxxxxxxxxxxxxxxx with a valid AMI ID for ap-south-1 (Mumbai)
  # This AMI should be RedHat-based (e.g., Amazon Linux, CentOS, RHEL) for the Jenkins playbook.
  ami           = "ami-0d03cb826412c6b0f"
  instance_type = "t2.medium"
  key_name      = "awskey" # Ensure this key pair exists in your AWS account
  subnet_id     = aws_subnet.sub1_project.id # Place in sub1-project
  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]
  root_block_device {
    volume_size = 14 # GiB
  }
  user_data = local.jenkins_user_data # Apply user data only to Jenkins

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_instance" "k8s_cp" {
  # IMPORTANT: Replace ami-xxxxxxxxxxxxxxxxx with a valid AMI ID for ap-south-1 (Mumbai)
  # This AMI should be Ubuntu-based for the Kubernetes playbook.
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t2.medium"
  key_name      = "awskey" # Ensure this key pair exists in your AWS account
  subnet_id     = aws_subnet.sub2_project.id # Place in sub2-project
  vpc_security_group_ids = [
    aws_security_group.k8s_cp_sg.id
  ]
  root_block_device {
    volume_size = 14 # GiB
  }
  user_data = local.ubuntu_user_data # Apply user data for Ubuntu instances

  tags = {
    Name = "945-Project-CP"
  }
}

resource "aws_instance" "node1" {
  # IMPORTANT: Replace ami-xxxxxxxxxxxxxxxxx with a valid AMI ID for ap-south-1 (Mumbai)
  # This AMI should be Ubuntu-based for the Kubernetes playbook.
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t2.medium"
  key_name      = "awskey" # Ensure this key pair exists in your AWS account
  subnet_id     = aws_subnet.sub3_project.id # Place in sub3-project
  vpc_security_group_ids = [
    aws_security_group.k8s_nodes_sg.id
  ]
  root_block_device {
    volume_size = 14 # GiB
  }
  user_data = local.ubuntu_user_data # Apply user data for Ubuntu instances

  tags = {
    Name = "Node1"
  }
}
