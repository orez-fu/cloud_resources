
resource "aws_service_discovery_private_dns_namespace" "discovery_namespace" {
  name        = "${var.project}-discovery-namespace"
  description = "Service Discovery Namespace"
  vpc         = data.aws_vpc.vpc.id
}

resource "aws_service_discovery_service" "discovery_service" {
  name = "${var.project}-discovery-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.discovery_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"

  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
