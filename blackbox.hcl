job "blackbox" {
  datacenters = ["dc1"]

  group "blackbox" {
    task "blackbox" {
      driver = "docker"

      config {
        image = "prom/blackbox-exporter:v0.15.0"

        network_mode = "host"

        volumes = [
          "./local/blackbox.yml:/blackbox.yml",
        ]

        args = [
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_http}",
          "--config.file=/blackbox.yml"
        ]
      }

      resources {
        cpu    = 100
        memory = 32

        network {
          port "http" {}
        }
      }

      template {
        data = <<EOH
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_status_codes: []
      method: GET
        EOH

        destination = "local/blackbox.yml"
      }

      service {
        name = "blackbox"
        port = "http"

        check {
          name     = "blackbox"
          type     = "http"
          path     = "/probe?target=google.com&module=http_2xx"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
