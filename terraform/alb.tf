resource "aws_lb" "app_lb" {
    name = "devops-alb"
    internal = false
    load_balancer_type = "application"
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "tg" {
    name = "devops-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"
}

resource "aws_lb_target_group" "green_tg" {
    name = "devops-green-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"

    health_check {
        path = "/health"
    }

}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = 80

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.green_tg.arn
    }
}