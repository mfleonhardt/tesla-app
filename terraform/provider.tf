terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.0"
        }
    }

    backend "s3" {
        bucket = "mleonhardt-terraform-state"
        key = "tesla-app"
        region = "us-west-1"
    }
}

provider "aws" {
    region = "us-west-1"
    alias = "us-west-1"
    default_tags {
        tags = {
            Project = "Tesla App"
        }
    }
}

provider "aws" {
    region = "us-east-1"
    alias = "us-east-1"
    default_tags {
        tags = {
            Project = "Tesla App"
        }
    }
}

resource "random_id" "tesla_app_suffix" {
    byte_length = 8
}