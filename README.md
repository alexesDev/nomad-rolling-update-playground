# Nomad rolling update playground

```bash
consul agent -dev
nomad agent -dev

nomad run traefik.hcl
nomad run blackbox.hcl
nomad run prometheus.hcl
nomad run example.hcl
nomad run grafana.hcl
```

- http://prometheus.localhost
- http://grafana.localhost (admin, password)
