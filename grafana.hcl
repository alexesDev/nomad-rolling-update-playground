job "grafana" {
  datacenters = ["dc1"]

  group "grafana" {
    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:6.2.5"

        network_mode = "host"

        volumes = [
          "./local/provisioning:/etc/grafana/provisioning",
          "./local/grafana.ini:/etc/grafana/grafana.ini",
        ]
      }

      env {
        GF_SERVER_ROOT_URL         = "http://grafana.${MAIN_DOMAIN}"
        GF_SECURITY_ADMIN_PASSWORD = "password"
      }

      template {
        data = <<EOH
apiVersion: 1

datasources:
{{ range service "prometheus" }}
  - name: {{ .Name }}
    type: prometheus
    access: proxy
    isDefault: true
    url: http://0.0.0.0:{{ .Port }}{{ end }}
        EOH

        destination = "local/provisioning/datasources/main.yml"
      }

      template {
        data = <<EOH
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "panels": [
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "fill": 1,
      "gridPos": {
        "h": 7,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 4,
      "interval": "",
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "options": {},
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "healthy",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "{{ name }}",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Healty",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "fill": 1,
      "gridPos": {
        "h": 6,
        "w": 24,
        "x": 0,
        "y": 7
      },
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "options": {},
      "percentage": false,
      "pointradius": 2,
      "points": true,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "probe_success",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Probe",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "refresh": "0.1s",
  "schemaVersion": 18,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1m",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "0.1s",
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "",
  "title": "New dashboard Copy",
  "uid": "JzjWpipWk",
  "version": 3
}
        EOH

        destination = "local/provisioning/dashboards/monitor.json"
      }

      template {
        data = <<EOH
apiVersion: 1

providers:
- name: 'prometheus'
  orgId: 1
  folder: ''
  type: file
  disableDeletion: false
  editable: true
  options:
    path: /etc/grafana/provisioning/dashboards
        EOH

        destination = "local/provisioning/dashboards/dashboard.yml"
      }

      template {
        data = <<EOH
[server]
http_port = {{ env "NOMAD_PORT_http" }}
        EOH

        destination = "local/grafana.ini"
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 1
          port  "http"{}
        }
      }

      service {
        name = "grafana"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.frontends.A.rule=Host:grafana.localhost",
        ]
      }
    }
  }
}
