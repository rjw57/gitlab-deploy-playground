# CloudSQL proxy
#
# In preference, containers should use the sidecar model for loading the
# cloudsql proxy next to them. For some containers, e.g. initContainers, this is
# not feasible so create a service for the CloudSQL proxy.
#
# Since this proxy should *not* be used for long-lived containers, we only have
# a small number of replicas to discourage use beyond initContainers.
resource "kubernetes_deployment" "cloud_sql_proxy" {
  metadata {
    name      = "cloud-sql-proxy"
    namespace = "${local.k8s_namespace}"

    labels {
      app = "cloud-sql-proxy"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels {
        app = "cloud-sql-proxy"
      }
    }

    template {
      metadata {
        labels {
          app = "cloud-sql-proxy"
        }
      }

      spec {
        container {
          name  = "cloudsql"
          image = "${var.cloud_sql_proxy_image}"

          command = [
            "/cloud_sql_proxy",
            "-instances=${var.sql_instance_connection_name}=tcp:0.0.0.0:5432",
            "-credential_file=/secrets/cloudsql/credentials.json",
          ]

          security_context {
            run_as_user     = 2    # some non-root user
            run_as_non_root = true
          }

          volume_mount {
            name       = "cloudsql-instance-credentials"
            mount_path = "/secrets/cloudsql"
            read_only  = true
          }
        }

        volume {
          name = "cloudsql-instance-credentials"

          secret {
            secret_name = "${local.db_proxy_credentials_secret}"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "cloud_sql_proxy" {
  metadata {
    name      = "cloud-sql-proxy"
    namespace = "${local.k8s_namespace}"
  }

  spec {
    selector {
      app = "${kubernetes_deployment.cloud_sql_proxy.metadata.0.labels.app}"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

locals {
  db_proxy_service = "${kubernetes_service.cloud_sql_proxy.metadata.0.name}"
}
