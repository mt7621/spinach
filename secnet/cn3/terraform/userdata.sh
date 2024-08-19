#!/bin/bash
echo "ec2-user:password" | sudo chpasswd
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
yum install -y lynx
aws configure set default.region ap-northeast-2
yum install python3-pip -y
pip install flask
pip install boto3