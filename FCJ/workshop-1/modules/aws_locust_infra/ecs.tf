
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project}-ecs-cluster"

  tags = merge({
    "Name" = "${var.project}-ecs-cluster"
    },
    var.tags
  )
}
