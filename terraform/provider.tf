terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.83.0"
   }
 }

  backend "s3" {
   bucket = "ilyas-state2"
   key    = "state"
   region = "us-east-2"
 }

}
