# Minecraft Server on AWS
This small project sets up a Minecraft server on AWS. 

## Features
Minecraft Server Deployment: Automatically deploy a Minecraft server on an EC2 instance using Terraform.

User Data Configuration: The server is configured using USER_DATA scripts during the EC2 instance launch.

Automated Backups: Daily snapshots of the server's EBS volume are created using a custom policy.

Security: The server is secured with a restricted Security Group, allowing access only to EC2 instance connect and Minecraft ports.

## License
This project is licensed under the [MIT](LICENSE).

