job "prometheus" {
  datacenters = ["dc1"]

  group "prometheus" {
    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.8.1"

        network_mode = "host"

        volumes = [
          "./local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]

        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_http}",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
        ]
      }

      template {
        data = <<EOH
alerting:
  alertmanagers:
    - consul_sd_configs:
        - services: ['alertmanager']

rule_files:
  - '/etc/prometheus/alerts.yml'

scrape_configs:
  - job_name: 'services'
    scrape_interval: 50ms
    consul_sd_configs:
      - server: '127.0.0.1:8500'
        services: []

    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*,metrics,.*
        action: keep
      - source_labels: [__meta_consul_service]
        target_label: job

  - job_name: 'blackbox'
    scrape_interval: 50ms
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://localhost
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: target
      - target_label: __address__
{{ range service "blackbox" }}
        replacement: {{ .Address }}:{{ .Port }}{{ end }}
        EOH

        destination = "local/prometheus.yml"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = 2500
        memory = 1024

        network {
          port "http" {}
        }
      }

      service {
        name = "prometheus"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.frontends.A.rule=Host:prometheus.localhost",
        ]

        check {
          name     = "prometheus"
          type     = "http"
          path     = "/targets"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
