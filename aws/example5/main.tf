module "vpc100" {
  source = "../../modules/aws/vpc"
  vpc_name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc100"
  vpc_cidr = "10.100.0.0/16"
  public_subnet_cidr1  = "10.100.11.0/24"
  private_subnet_cidr1 = "10.100.12.0/24"
  public_subnet_cidr2  = "10.100.21.0/24"
  private_subnet_cidr2 = "10.100.22.0/24"
}


resource "aws_security_group" "this" {
  name_prefix = "${lower(var.app_name)}-${lower(var.app_environment)}-sg"
  vpc_id      = module.vpc100.vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${lower(var.app_name)}-${lower(var.app_environment)}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}


resource "aws_ecs_cluster" "this" {
  name = "${lower(var.app_name)}-${lower(var.app_environment)}-cluster"
  
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${lower(var.app_name)}-${lower(var.app_environment)}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([{
    name            = "${lower(var.app_name)}-${lower(var.app_environment)}-container"
    image           = "nginx:latest"
    portMappings    = [{ containerPort = 80 }]
  }])
  memory                   = 3072
  cpu                      = 1024
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${lower(var.app_name)}-${lower(var.app_environment)}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  # Assign an Elastic IP address to the task
  network_configuration {
    assign_public_ip = true
    subnets          = [module.vpc100.public_subnet1_id,module.vpc100.public_subnet2_id]
    security_groups  = [aws_security_group.this.id]
  }

  # Configure the service to use Fargate
  launch_type = "FARGATE"

  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-container"
  }

}

# This will always run to retrieve the public IP until better solution is found
resource "null_resource" "publicip" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOF
        clustername=${lower(var.app_name)}-${lower(var.app_environment)}-cluster
        taskid=$(aws ecs list-tasks --cluster $clustername --query "taskArns[0]" --output text)
        eni=$(aws ecs describe-tasks --tasks $taskid --cluster $clustername --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)
        publicip=$(aws ec2 describe-network-interfaces --query "NetworkInterfaces[?NetworkInterfaceId=='$eni'].Association.PublicIp" --output text)
        echo "$publicip"
    EOF
  }

  depends_on = [
    aws_ecs_service.this
  ]
}

