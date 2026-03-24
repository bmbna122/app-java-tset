resource "aws_iam_role" "codedeploy_role" {
    name = "CodeDeployECSRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "codedeploy.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
    role = aws_iam_role.codedeploy_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_codedeploy_app" "app" {
    name = "devops-app"
    compute_platform = "ECS"
}

data "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = 80
}

resource "aws_codedeploy_deployment_group" "dg" {
    app_name = aws_codedeploy_app.app.name
    deployment_group_name = "devops-dg"
    service_role_arn = aws_iam_role.codedeploy_role.arn

    deployment_config_name = "CodeDeployDefault.ECSALLAtOnce"

    ecs_service {
        cluster_name = aws_ecs_cluster.main.name
        service_name = aws_ecs_service.app.name
    }

    load_balancer_info {
        target_group_pair_info {
            target_group {
                name = aws_lb_target_group.tg.name
            }

            target_group {
                name = aws_lb_target_group.green_tg.name
            }

            prod_traffic_route {
                listener_arns = [data.aws_lb_listener.http.arn]
            }
        }
    }

    
}