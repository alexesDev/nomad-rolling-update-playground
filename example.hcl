job "example" {
  datacenters = ["dc1"]

  group "example" {
    count = 5

    update {
      max_parallel = 1
      min_healthy_time = "5s"
      healthy_deadline = "5m"
      progress_deadline = "10m"
      auto_revert = true
    }

    task "example" {
      driver = "docker"
      # kill_timeout = "120s"
      # kill_signal = "SIGTERM"
      # shutdown_delay = "10s"

      config {
        image = "alexes/service:v1"
        network_mode = "host"
        args = ["/app", "-listen-addr", "${NOMAD_ADDR_http}"]
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 1
          port "http" {}
        }
      }

      env {
        NOMAD_ALLOC_ID = "v7 ${NOMAD_ALLOC_INDEX}"
      }

      service {
        name = "example"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.frontends.A.rule=Host:localhost",
          "metrics"
        ]

        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }
}
