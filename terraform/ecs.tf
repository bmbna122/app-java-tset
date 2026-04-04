resource "aws_ecs_cluster" "main" {
    name = "devops-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
    name = "/ecs/devops-app"
    retention_in_days = 7
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
    family = "devops-task"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = "256"
    memory = "512"
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([
        {
            name = "app"
            image = var.container_image
            essential = true
            portMappings= [{
                containerPort = 80
                hostPort = 80
                protocol = "tcp"
            }]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = "/ecs/devops-app"
                    awslogs-region = "us-east-1"
                    awslogs-stream-prefix = "ecs"
                }
            }
        }
    ])
}

resource "aws_ecs_service" "app" {
    name = "devops-service"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count = 1
    launch_type = "FARGATE"

    deployment_controller {
        type = "ECS"
    }

    network_configuration {
        subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
        assign_public_ip = true
        security_groups = [aws_security_group.ecs_sg.id]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.green_tg.arn
        container_name = "app"
        container_port = 80
    }

    depends_on = [aws_lb_listener.listener]
}

resource "aws_ecs_service" "blue" {
    name = "devops-service-blue"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
        subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
        security_groups = [aws_security_group.ecs_sg.id]
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.tg.arn
        container_name = "app"
        container_port = 80
    }

    depends_on = [
        aws_lb_listener.listener
    ]
}