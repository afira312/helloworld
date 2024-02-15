terraform {
  required_version = ">= 1.3.9"
}

variable "subject" {
   type = string
   default = "World"
   description = "Subject to hello"
}

resource "random_id" "id" {
  keepers = {
    trigger = var.subject
  }

  byte_length = 4
}
resource "kubernetes_pod_v1" "test" {
  metadata {
    name = "terraform-example"
    namespace = "flux-system"
  }

  spec {
    container {
      image = "nginx:1.21.6"
      name  = "example"

      env {
        name  = "environment"
        value = "test"
      }

      port {
        container_port = 80
      }

      liveness_probe {
        http_get {
          path = "/"
          port = 80

          http_header {
            name  = "X-Custom-Header"
            value = "Awesome"
          }
        }

        initial_delay_seconds = 3
        period_seconds        = 3
      }
    }

    dns_config {
      nameservers = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
      searches    = ["example.com"]

      option {
        name  = "ndots"
        value = 1
      }

      option {
        name = "use-vc"
      }
    }

    dns_policy = "None"
  }
}
output "hello_world" {
  value = "Hello World, ${var.subject} ${random_id.id.hex}!"
}
