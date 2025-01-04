resource "aws_ecs_cluster" "my_app_cluster" {
  name = "${var.project-name}-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "${var.project-name}-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name        = var.project-name,
      image       = "975050213689.dkr.ecr.us-east-2.amazonaws.com/my-app:latest", # Replace with your ECR image URI
      essential   = true,
      logConfiguration = {
        logDriver     = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
    ]
  )
}


# Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-task-sg"
  description = "Allow HTTP traffic to ECS tasks"
  vpc_id      = aws_default_vpc.default.id # Replace with your VPC ID

  ingress {
    from_port        = 0
    self             = true
    to_port          = 0
    protocol         = "-1"
    security_groups  = []
    cidr_blocks      = [] # Adjust for your requirements
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "main" {
 cluster         = aws_ecs_cluster.my_app_cluster.id
 desired_count   = 1
 launch_type     = "FARGATE"
 name            = "${var.project-name}-service"
 task_definition = aws_ecs_task_definition.my_task.arn

 network_configuration {
   subnets          = [aws_default_subnet.public_subnet1.id, aws_default_subnet.public_subnet2.id] # Replace with your subnet IDs
   security_groups  = [aws_security_group.ecs_sg.id]                                               # Replace with your security group
   assign_public_ip = true     # Assign public IP if needed
 }
}
