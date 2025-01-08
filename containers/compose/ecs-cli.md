```
This is an explanation of my experiments with ecs-cli
```
## 1. configure service in this directory
```
ecs-cli configure --cluster my-app-cluster --region us-east-2 --default-launch-type FARGATE
```

### OR

```
 ecs-cli configure --cluster my-app-cluster-ec2 --region us-east-2 --default-launch-type EC2
 ecs-cli up --keypair personal-mac --capability-iam --size 2 --instance-type t2.micro
```
#### None of that is really working, just there ;-(

