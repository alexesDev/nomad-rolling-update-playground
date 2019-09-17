job "traefik" {
  datacenters = ["dc1"]

  group "traefik" {
    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v1.7.14-alpine"
        network_mode = "host"

        volumes = [
          "./local/treafik.toml:/etc/traefik/traefik.toml",
        ]
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 1
          port "ping" {}
        }
      }

      template {
        destination   = "local/treafik.toml"
        data = <<EOH
defaultEntryPoints = ["http"]

[ping]
entryPoint = "internal"

[api]
entryPoint = "internal"
dashboard = true

[consulCatalog]
exposedByDefault = false

[entryPoints]
  [entryPoints.http]
  address = ":80"

  [entryPoints.internal]
  address = ":{{ env "NOMAD_PORT_ping" }}"
EOH
      }

      service {
        name = "traefik"
        port = "ping"

        check {
          name     = "alive"
          type     = "http"
          path     = "/ping"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
