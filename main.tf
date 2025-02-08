provider "aws" {
  region = local.region_base
  # profile = "zeeward41"
  default_tags {
    tags = {
      Creator = "Zeeward41"
      Project = "${local.project_name}"
    }
  }
}

# Creation d'un IAM role
resource "aws_iam_role" "dlm_role" {
  name = "dlm_role_minecraft"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "dlm.amazonaws.com"
        //Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
    }
  )

}

# Creation de la policy dlm
resource "aws_iam_policy" "dlm_policy" {
  name        = "dlm_policy"
  description = "Policy qui permet de gerer les Snapshots EBS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",

        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*::snapshot/*"
      }
    ]
    }

  )
}

# Attache la policy au Iam Role
resource "aws_iam_role_policy_attachment" "dlm_role_policy" {
  role       = aws_iam_role.dlm_role.name
  policy_arn = aws_iam_policy.dlm_policy.arn
}


# ID Default VPC
data "aws_vpc" "default" {
  default = true
}

#Security Group EC2 instance
resource "aws_security_group" "minecraft_server" {
  description = "autorise uniquement EC2 connect"
  vpc_id      = data.aws_vpc.default.id
  name        = "SG_minecraft_server"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.ec2_connect_us_east_1]
  }
  # Règle pour le port 25565
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## EC2 instance
resource "aws_instance" "server" {
  instance_type          = "t2.small"
  ami                    = local.ami_ec2_t2_micro_us_east_1
  vpc_security_group_ids = [aws_security_group.minecraft_server.id]

  user_data = <<EOF
#!/bin/bash

# Créer le répertoire Minecraft
mkdir /home/ec2-user/minecraft
cd /home/ec2-user/minecraft

# Installer Java
sudo yum install -y java-21-amazon-corretto-devel

# Télécharger le fichier JAR du serveur Minecraft
sudo wget https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar


# Rendre le fichier JAR exécutable
sudo chmod +x /home/ec2-user/minecraft/server.jar

# Accepter le contrat de licence du serveur Minecraft
echo "eula=true" > /home/ec2-user/minecraft/eula.txt

# Démarrer le serveur Minecraft
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui

EOF

  tags = {
    Name = "Minecraft_Server"
  }
  volume_tags = {
    Project = "Minecraft_Server_V1-Terraform"
    Name    = "Minecraft_Server"
  }
}

# Creation du Dlm lifecycle policy
resource "aws_dlm_lifecycle_policy" "minecraft" {
  description        = "Daily Save du volume EBS du serveur Minecraft"
  execution_role_arn = aws_iam_role.dlm_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["19:58"]
      }

      retain_rule {
        count = 3
      }

      tags_to_add = {
        SnapshotCreator = "DLM_ZEE"
      }

      copy_tags = false
    }
    target_tags = {
      Project = "Minecraft_Server_V1-Terraform"
      Name    = "Minecraft_Server"
    }
  }
}