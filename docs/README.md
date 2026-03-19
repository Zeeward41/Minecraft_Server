# Minecraft Server on AWS – My First Terraform Project

Small AWS project: automated deployment of a Minecraft server using Terraform.

This was my **very first real IaC project** — before moving to the Cloud Resume Challenge (serverless website) and then ZeeURL (full Kubernetes + GitOps stack).

## Features

- EC2 instance (t2.small) with Minecraft server pre-configured via user data
- Security Group restricted (SSH via EC2 Instance Connect + port 25565 open)
- Daily automated EBS volume snapshots via AWS DLM (Data Lifecycle Manager)
- Custom IAM role + policy for snapshot management
- All infrastructure defined with **Terraform** (no manual clicks)

## Tech Stack

| Layer      | Technologies                  |
| ---------- | ----------------------------- |
| Compute    | EC2 (t2.small)                |
| Storage    | EBS volume + DLM snapshots    |
| IaC        | Terraform                     |
| Security   | Security Groups + IAM role    |
| Automation | User data script (Java + JAR) |

## Architecture

1. Terraform → creates EC2 + SG + IAM role + DLM policy
2. User data script → installs Java, downloads Minecraft JAR, accepts EULA, starts server
3. DLM → daily snapshot of the EBS volume (retain 3 days)

## How to Explore

Not designed for easy local reproduction (requires AWS account, Terraform state, etc.).

To understand:

1. Review Terraform code: `main.tf` + `local_variable.tf`
2. Check DLM lifecycle policy + IAM role/policy
3. See user data script inside `aws_instance` resource

## Why I Built It

My very first hands-on project to learn:

- Terraform basics (providers, resources, data sources)
- EC2 launch with user data
- IAM roles & policies
- AWS backup automation (DLM)

After this, I built the [Cloud Resume Challenge](https://github.com/zeeward41/cloud_resume_challenge) (serverless + CI/CD), then ZeeURL (Kubernetes + GitOps full app).

## License

[MIT License](License.md)

**Personal note**  
100% solo — first step in my career transition (2024).  
Led to Cloud Resume Challenge, then ZeeURL.  
AWS Certified Solutions Architect – Associate.
