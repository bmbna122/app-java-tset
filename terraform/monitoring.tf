resource "aws_sns_topic" "alerts" {
    name = "devops-alerts"
}

resource "aws_sns_topic_subscription" "email" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol = "email"
    endpoint = "bmb19967@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
    alarm_name = "ecs-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/ECS"
    period = 60
    statistic = "Average"
    threshold = 70

    dimensions = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.app.name
    }

    alarm_description = "Alarm when ECS CPU exceeds 70%"
    alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
    alarm_name = "alb-5xx-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "HTTPCode_Target_5XX_Count"
    namespace = "AWS/ApplicationELB"
    period = 60
    statistic = "Sum"
    threshold = 5

    dimensions = {
        LoadBalancer = aws_lb.app_lb.arn_suffix
    }

    alarm_description = "Alarm when ALB returns more than 5 5xx errors in a minute"
    alarm_actions = [aws_sns_topic.alerts.arn]
}